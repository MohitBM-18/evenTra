import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/enums.dart';
import 'notification_provider.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  NotificationProvider? _notificationProvider;
  bool _isLoaded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _currentUserId;
  UserRole? _currentUserRole;

  BookingProvider([this._notificationProvider]);

  void updateNotif(NotificationProvider notif) {
    _notificationProvider = notif;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Reference to the Firestore 'bookings' collection.
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('bookings');

  List<BookingModel> get bookings => _bookings;
  bool get isLoaded => _isLoaded;

  // -- Getters for various statuses --

  List<BookingModel> userBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  List<BookingModel> get pendingFacultyBookings =>
      _bookings.where((b) => b.status == BookingStatus.pendingFaculty).toList();

  List<BookingModel> get pendingHodBookings =>
      _bookings.where((b) => b.status == BookingStatus.pendingHod).toList();

  List<BookingModel> get pendingVenueBookings =>
      _bookings.where((b) => b.status == BookingStatus.pendingVenue).toList();

  List<BookingModel> get confirmedBookings =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).toList();

  List<BookingModel> get rejectedBookings =>
      _bookings.where((b) => b.status == BookingStatus.rejected).toList();

  List<BookingModel> get changesRequestedBookings =>
      _bookings.where((b) => b.status == BookingStatus.changesRequested).toList();

  /// Start listening to bookings from Firestore in real-time.
  /// Admin roles listen to all, students only listen to their own.
  Future<void> loadBookings(String userId, UserRole role) async {
    if (_isLoaded && _currentUserId == userId && _currentUserRole == role) return;
    _currentUserId = userId;
    _currentUserRole = role;
    _isLoaded = true;
    
    _subscription?.cancel();

    Query<Map<String, dynamic>> query = _collection.orderBy('createdAt', descending: true);

    if (role == UserRole.studentCoordinator) {
      // Students only see their own bookings
      query = _collection.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true);
    }

    _subscription = query.snapshots().listen(
      (snapshot) {
        _bookings = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('BookingProvider real-time listener error: $e');
      },
    );
  }

  void clearBookings() {
    _currentUserId = null;
    _currentUserRole = null;
    _subscription?.cancel();
    _bookings = [];
    _isLoaded = false;
    notifyListeners();
  }

  Future<void> createBooking(BookingModel booking) async {
    try {
      final docRef = await _collection.add(booking.toFirestore());
      
      // Update the document with its own generated ID if needed, though Firestore ID is usually enough.
      // But we have our custom `bookingId` like 'EVT-...' which we can keep.

      _notificationProvider?.addNotification(
        booking.userId,
        'Booking Submitted',
        'Your request for ${booking.auditoriumName} on ${booking.eventName} has been submitted to your Faculty Coordinator.',
        type: NotificationType.bookingSubmitted,
        bookingId: docRef.id,
      );

      // In a real app, send notification to Faculty Coordinator as well
    } catch (e) {
      debugPrint('BookingProvider.createBooking error: $e');
    }
  }

  Future<void> approveBooking(String id, String approverId, String approverName, UserRole approverRole, {String comment = ''}) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];
      ApprovalStage nextStage = currentBooking.approvalStage;
      BookingStatus nextStatus = currentBooking.status;

      String actionStr = 'approved';

      if (currentBooking.approvalStage == ApprovalStage.submitted) {
        nextStage = ApprovalStage.facultyApproved;
        nextStatus = BookingStatus.pendingHod;
      } else if (currentBooking.approvalStage == ApprovalStage.facultyApproved) {
        nextStage = ApprovalStage.hodApproved;
        nextStatus = BookingStatus.pendingVenue;
      } else if (currentBooking.approvalStage == ApprovalStage.hodApproved) {
        nextStage = ApprovalStage.venueApproved;
        nextStatus = BookingStatus.confirmed;
      } else if (currentBooking.approvalStage == ApprovalStage.changesRequested) {
         // If they re-submit/approve after changes, we might need a more complex state machine
         // For now, bump to the appropriate next pending state or just pendingFaculty
         nextStage = ApprovalStage.submitted;
         nextStatus = BookingStatus.pendingFaculty;
         actionStr = 're-submitted';
      }

      final approvalRecord = ApprovalRecord(
        approverName: approverName,
        approverRole: approverRole.displayName,
        action: actionStr,
        timestamp: DateTime.now(),
        comment: comment,
      );

      final updated = currentBooking.copyWith(
        approvalStage: nextStage,
        status: nextStatus,
        approvalHistory: [...currentBooking.approvalHistory, approvalRecord],
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.approveBooking error: $e');
      }

      if (nextStatus == BookingStatus.confirmed) {
        _notificationProvider?.addNotification(
          currentBooking.userId,
          'Booking Confirmed',
          '${currentBooking.eventName} at ${currentBooking.auditoriumName} is fully confirmed.',
          type: NotificationType.bookingConfirmed,
          bookingId: id,
        );
      } else {
        _notificationProvider?.addNotification(
          currentBooking.userId,
          'Booking Progressed',
          '${currentBooking.eventName} was approved by $approverName and is now ${nextStatus.displayName}.',
          type: NotificationType.bookingApproved,
          bookingId: id,
        );
      }
    }
  }

  Future<void> rejectBooking(String id, String approverId, String approverName, UserRole approverRole, String reason) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];
      
      final approvalRecord = ApprovalRecord(
        approverName: approverName,
        approverRole: approverRole.displayName,
        action: 'rejected',
        timestamp: DateTime.now(),
        comment: reason,
      );

      final updated = currentBooking.copyWith(
        status: BookingStatus.rejected,
        approvalStage: ApprovalStage.rejected,
        approvalHistory: [...currentBooking.approvalHistory, approvalRecord],
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.rejectBooking error: $e');
      }

      _notificationProvider?.addNotification(
        currentBooking.userId,
        'Booking Rejected',
        'Request for ${currentBooking.auditoriumName} was rejected by $approverName: $reason',
        type: NotificationType.bookingRejected,
        bookingId: id,
      );
    }
  }

  Future<void> requestChanges(String id, String approverId, String approverName, UserRole approverRole, String reason) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];
      
      final approvalRecord = ApprovalRecord(
        approverName: approverName,
        approverRole: approverRole.displayName,
        action: 'changes_requested',
        timestamp: DateTime.now(),
        comment: reason,
      );

      final updated = currentBooking.copyWith(
        status: BookingStatus.changesRequested,
        approvalStage: ApprovalStage.changesRequested,
        approvalHistory: [...currentBooking.approvalHistory, approvalRecord],
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.requestChanges error: $e');
      }

      _notificationProvider?.addNotification(
        currentBooking.userId,
        'Changes Requested',
        '$approverName requested changes for ${currentBooking.eventName}: $reason',
        type: NotificationType.changesRequested,
        bookingId: id,
      );
    }
  }


  Future<void> forceApproveBooking(String id, String approverName) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];

      final approvalRecord = ApprovalRecord(
        approverName: approverName,
        approverRole: 'Administrator',
        action: 'force_approved',
        timestamp: DateTime.now(),
        comment: 'Force approved by Super Admin.',
      );

      final updated = currentBooking.copyWith(
        status: BookingStatus.confirmed,
        approvalStage: ApprovalStage.venueApproved,
        approvalHistory: [...currentBooking.approvalHistory, approvalRecord],
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.forceApproveBooking error: $e');
      }

      _notificationProvider?.addNotification(
        currentBooking.userId,
        'Booking Force Approved',
        '${currentBooking.eventName} at ${currentBooking.auditoriumName} was force approved.',
        type: NotificationType.bookingConfirmed,
        bookingId: id,
      );
    }
  }

  Future<void> forceRejectBooking(String id, String approverName) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];

      final approvalRecord = ApprovalRecord(
        approverName: approverName,
        approverRole: 'Administrator',
        action: 'force_rejected',
        timestamp: DateTime.now(),
        comment: 'Force rejected by Super Admin.',
      );

      final updated = currentBooking.copyWith(
        status: BookingStatus.rejected,
        approvalStage: ApprovalStage.rejected,
        approvalHistory: [...currentBooking.approvalHistory, approvalRecord],
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.forceRejectBooking error: $e');
      }

      _notificationProvider?.addNotification(
        currentBooking.userId,
        'Booking Force Rejected',
        'Request for ${currentBooking.auditoriumName} was force rejected.',
        type: NotificationType.bookingRejected,
        bookingId: id,
      );
    }
  }

  Future<void> cancelBooking(String id) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      try {
        await _collection.doc(id).update(updated.toFirestore());
      } catch (e) {
        debugPrint('BookingProvider.cancelBooking error: $e');
      }
    }
  }

  List<BookingModel> getBookingsForAuditorium(String auditoriumId) {
    return _bookings.where((b) => b.auditoriumId == auditoriumId).toList();
  }

  List<BookingModel> getBookingsForDate(DateTime date) {
    return _bookings.where((b) =>
      b.date.year == date.year &&
      b.date.month == date.month &&
      b.date.day == date.day
    ).toList();
  }

  Map<String, dynamic> getBookingStats() {
    return {
      'totalBookings': _bookings.length,
      'pendingCount': pendingFacultyBookings.length + pendingHodBookings.length + pendingVenueBookings.length,
      'confirmedCount': confirmedBookings.length,
      'rejectedCount': rejectedBookings.length,
    };
  }

  /// Checks if an auditorium is available on a specific date and time slot.
  /// Also checks pending bookings to avoid double-booking overlaps.
  bool isSlotAvailable(String auditoriumId, DateTime date, String startTime, String endTime, {String? excludeBookingId}) {
    // Basic time parser to compare times like '10:00 AM'
    int timeToMinutes(String t) {
      if (t.isEmpty) return 0;
      try {
        final parts = t.split(' ');
        final timeParts = parts[0].split(':');
        int hours = int.parse(timeParts[0]);
        final int mins = int.parse(timeParts[1]);
        if (parts[1].toUpperCase() == 'PM' && hours < 12) hours += 12;
        if (parts[1].toUpperCase() == 'AM' && hours == 12) hours = 0;
        return hours * 60 + mins;
      } catch (e) {
        return 0; // Fallback
      }
    }

    final reqStart = timeToMinutes(startTime);
    final reqEnd = timeToMinutes(endTime);

    final relevantBookings = _bookings.where((b) =>
      b.id != excludeBookingId &&
      b.auditoriumId == auditoriumId &&
      b.date.year == date.year &&
      b.date.month == date.month &&
      b.date.day == date.day &&
      (b.status == BookingStatus.confirmed || b.status.isPending)
    );
    
    for (var b in relevantBookings) {
      final bStart = timeToMinutes(b.startTime);
      final bEnd = timeToMinutes(b.endTime);

      // Overlap condition:
      // (StartA < EndB) and (EndA > StartB)
      if (reqStart < bEnd && reqEnd > bStart) {
        return false; // Conflict found
      }
    }

    return true; // No conflicts
  }
}
