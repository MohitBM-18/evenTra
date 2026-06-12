import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/enums.dart';
import '../data/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingModel> _bookings = List.from(MockData.bookings);

  List<BookingModel> get bookings => _bookings;

  List<BookingModel> userBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  List<BookingModel> get pendingBookings {
    return _bookings.where((b) => b.status == BookingStatus.pending).toList();
  }

  List<BookingModel> get approvedBookings {
    return _bookings.where((b) => b.status == BookingStatus.approved).toList();
  }

  List<BookingModel> get rejectedBookings {
    return _bookings.where((b) => b.status == BookingStatus.rejected).toList();
  }

  void createBooking(BookingModel booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void approveBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final currentBooking = _bookings[index];
      ApprovalStage nextStage = currentBooking.approvalStage;
      BookingStatus nextStatus = currentBooking.status;

      if (currentBooking.approvalStage == ApprovalStage.submitted) {
        nextStage = ApprovalStage.coordinatorApproved;
      } else if (currentBooking.approvalStage == ApprovalStage.coordinatorApproved) {
        nextStage = ApprovalStage.hodApproved;
      } else if (currentBooking.approvalStage == ApprovalStage.hodApproved) {
        nextStage = ApprovalStage.venueInChargeApproved;
        nextStatus = BookingStatus.approved;
      }

      _bookings[index] = currentBooking.copyWith(
        approvalStage: nextStage,
        status: nextStatus,
      );
      notifyListeners();
    }
  }

  void rejectBooking(String id, String reason) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.rejected,
        approvalStage: ApprovalStage.rejected,
      );
      notifyListeners();
    }
  }

  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      notifyListeners();
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
      'pendingCount': pendingBookings.length,
      'approvedCount': approvedBookings.length,
      'rejectedCount': rejectedBookings.length,
    };
  }

  bool isSlotAvailable(String auditoriumId, DateTime date, String startTime, String endTime) {
    // Basic mock check - a real implementation would parse times and check overlaps
    final existingBookings = _bookings.where((b) =>
      b.auditoriumId == auditoriumId &&
      b.date.year == date.year &&
      b.date.month == date.month &&
      b.date.day == date.day &&
      b.status == BookingStatus.approved
    );
    
    // For demo purposes, just check if there's any approved booking for that day
    return existingBookings.isEmpty;
  }
}
