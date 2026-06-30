import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Represents an approval action in the booking timeline.
class ApprovalRecord {
  final String approverName;
  final String approverRole;
  final String action; // 'approved', 'rejected', 'changes_requested'
  final DateTime timestamp;
  final String comment;

  ApprovalRecord({
    required this.approverName,
    required this.approverRole,
    required this.action,
    required this.timestamp,
    this.comment = '',
  });

  Map<String, dynamic> toMap() => {
    'approverName': approverName,
    'approverRole': approverRole,
    'action': action,
    'timestamp': Timestamp.fromDate(timestamp),
    'comment': comment,
  };

  factory ApprovalRecord.fromMap(Map<String, dynamic> map) => ApprovalRecord(
    approverName: map['approverName'] ?? '',
    approverRole: map['approverRole'] ?? '',
    action: map['action'] ?? '',
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    comment: map['comment'] ?? '',
  );
}

class BookingModel {
  final String id;
  final String bookingId; // Human-readable: EVT-20260618-001
  final String auditoriumId;
  final String auditoriumName;
  final String userId;
  final String userName;
  final String userRole;
  final String eventName;
  final String eventDescription;
  final String eventCategory; // was: purpose
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final ApprovalStage approvalStage;
  final int attendees;
  final List<String> equipment;
  final String clubOrDepartment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String organizerName; // was: userName (for organizer display)
  final String organizerContact; // phone number
  final String guestDetails;
  final String techSetup;
  final String securityDetails;
  final List<String> refreshments;
  final String coordinatorNote;
  final List<ApprovalRecord> approvalHistory;
  final List<String> resourcesRequested;

  BookingModel({
    required this.id,
    this.bookingId = '',
    required this.auditoriumId,
    required this.auditoriumName,
    required this.userId,
    required this.userName,
    this.userRole = '',
    required this.eventName,
    required this.eventDescription,
    this.eventCategory = 'Academic',
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.approvalStage = ApprovalStage.submitted,
    required this.attendees,
    required this.equipment,
    required this.clubOrDepartment,
    required this.createdAt,
    DateTime? updatedAt,
    String? organizerName,
    this.organizerContact = '',
    this.guestDetails = '',
    this.techSetup = '',
    this.securityDetails = '',
    this.refreshments = const [],
    this.coordinatorNote = '',
    this.approvalHistory = const [],
    this.resourcesRequested = const [],
  })  : updatedAt = updatedAt ?? createdAt,
        organizerName = organizerName ?? userName;

  // Backward compat alias
  String get purpose => eventCategory;

  BookingModel copyWith({
    String? id,
    String? bookingId,
    String? auditoriumId,
    String? auditoriumName,
    String? userId,
    String? userName,
    String? userRole,
    String? eventName,
    String? eventDescription,
    String? eventCategory,
    DateTime? date,
    String? startTime,
    String? endTime,
    BookingStatus? status,
    ApprovalStage? approvalStage,
    int? attendees,
    List<String>? equipment,
    String? clubOrDepartment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? organizerName,
    String? organizerContact,
    String? guestDetails,
    String? techSetup,
    String? securityDetails,
    List<String>? refreshments,
    String? coordinatorNote,
    List<ApprovalRecord>? approvalHistory,
    List<String>? resourcesRequested,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      auditoriumId: auditoriumId ?? this.auditoriumId,
      auditoriumName: auditoriumName ?? this.auditoriumName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventCategory: eventCategory ?? this.eventCategory,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      approvalStage: approvalStage ?? this.approvalStage,
      attendees: attendees ?? this.attendees,
      equipment: equipment ?? this.equipment,
      clubOrDepartment: clubOrDepartment ?? this.clubOrDepartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organizerName: organizerName ?? this.organizerName,
      organizerContact: organizerContact ?? this.organizerContact,
      guestDetails: guestDetails ?? this.guestDetails,
      techSetup: techSetup ?? this.techSetup,
      securityDetails: securityDetails ?? this.securityDetails,
      refreshments: refreshments ?? this.refreshments,
      coordinatorNote: coordinatorNote ?? this.coordinatorNote,
      approvalHistory: approvalHistory ?? this.approvalHistory,
      resourcesRequested: resourcesRequested ?? this.resourcesRequested,
    );
  }

  /// Convert to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'auditoriumId': auditoriumId,
      'auditoriumName': auditoriumName,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'eventName': eventName,
      'eventDescription': eventDescription,
      'eventCategory': eventCategory,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'approvalStage': approvalStage.name,
      'attendees': attendees,
      'equipment': equipment,
      'clubOrDepartment': clubOrDepartment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'organizerName': organizerName,
      'organizerContact': organizerContact,
      'guestDetails': guestDetails,
      'techSetup': techSetup,
      'securityDetails': securityDetails,
      'refreshments': refreshments,
      'coordinatorNote': coordinatorNote,
      'approvalHistory': approvalHistory.map((a) => a.toMap()).toList(),
      'resourcesRequested': resourcesRequested,
    };
  }

  /// Create a BookingModel from a Firestore document snapshot.
  factory BookingModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BookingModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      auditoriumId: data['auditoriumId'] ?? '',
      auditoriumName: data['auditoriumName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userRole: data['userRole'] ?? '',
      eventName: data['eventName'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      eventCategory: data['eventCategory'] ?? data['purpose'] ?? 'Academic',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: _parseBookingStatus(data['status']),
      approvalStage: _parseApprovalStage(data['approvalStage']),
      attendees: data['attendees'] ?? 0,
      equipment: List<String>.from(data['equipment'] ?? []),
      clubOrDepartment: data['clubOrDepartment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      organizerName: data['organizerName'] ?? data['userName'] ?? '',
      organizerContact: data['organizerContact'] ?? '',
      guestDetails: data['guestDetails'] ?? '',
      techSetup: data['techSetup'] ?? '',
      securityDetails: data['securityDetails'] ?? '',
      refreshments: List<String>.from(data['refreshments'] ?? []),
      coordinatorNote: data['coordinatorNote'] ?? '',
      approvalHistory: (data['approvalHistory'] as List<dynamic>?)
              ?.map((e) => ApprovalRecord.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      resourcesRequested: List<String>.from(data['resourcesRequested'] ?? []),
    );
  }

  /// Parse status with backward compat for old enum values.
  static BookingStatus _parseBookingStatus(String? value) {
    if (value == null) return BookingStatus.pendingFaculty;
    // Handle old enum names
    switch (value) {
      case 'pending':
        return BookingStatus.pendingFaculty;
      case 'approved':
        return BookingStatus.confirmed;
      default:
        return BookingStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => BookingStatus.pendingFaculty,
        );
    }
  }

  /// Parse approval stage with backward compat.
  static ApprovalStage _parseApprovalStage(String? value) {
    if (value == null) return ApprovalStage.submitted;
    // Handle old enum names
    switch (value) {
      case 'coordinatorApproved':
        return ApprovalStage.facultyApproved;
      case 'hodApproved':
        return ApprovalStage.hodApproved;
      case 'venueInChargeApproved':
        return ApprovalStage.venueApproved;
      default:
        return ApprovalStage.values.firstWhere(
          (e) => e.name == value,
          orElse: () => ApprovalStage.submitted,
        );
    }
  }

  /// Generate a human-readable booking ID.
  static String generateBookingId() {
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = now.millisecondsSinceEpoch.toString().substring(8);
    return 'EVT-$date-$seq';
  }
}
