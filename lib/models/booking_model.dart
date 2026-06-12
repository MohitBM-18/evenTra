import 'enums.dart';

class BookingModel {
  final String id;
  final String auditoriumId;
  final String auditoriumName;
  final String userId;
  final String userName;
  final String eventName;
  final String eventDescription;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final ApprovalStage approvalStage;
  final int attendees;
  final List<String> equipment;
  final String clubOrDepartment;
  final String purpose;
  final DateTime createdAt;
  final String guestDetails;
  final String techSetup;
  final String securityDetails;

  BookingModel({
    required this.id,
    required this.auditoriumId,
    required this.auditoriumName,
    required this.userId,
    required this.userName,
    required this.eventName,
    required this.eventDescription,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.approvalStage = ApprovalStage.submitted,
    required this.attendees,
    required this.equipment,
    required this.clubOrDepartment,
    required this.purpose,
    required this.createdAt,
    this.guestDetails = '',
    this.techSetup = '',
    this.securityDetails = '',
  });

  BookingModel copyWith({
    String? id,
    String? auditoriumId,
    String? auditoriumName,
    String? userId,
    String? userName,
    String? eventName,
    String? eventDescription,
    DateTime? date,
    String? startTime,
    String? endTime,
    BookingStatus? status,
    ApprovalStage? approvalStage,
    int? attendees,
    List<String>? equipment,
    String? clubOrDepartment,
    String? purpose,
    DateTime? createdAt,
    String? guestDetails,
    String? techSetup,
    String? securityDetails,
  }) {
    return BookingModel(
      id: id ?? this.id,
      auditoriumId: auditoriumId ?? this.auditoriumId,
      auditoriumName: auditoriumName ?? this.auditoriumName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      approvalStage: approvalStage ?? this.approvalStage,
      attendees: attendees ?? this.attendees,
      equipment: equipment ?? this.equipment,
      clubOrDepartment: clubOrDepartment ?? this.clubOrDepartment,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      guestDetails: guestDetails ?? this.guestDetails,
      techSetup: techSetup ?? this.techSetup,
      securityDetails: securityDetails ?? this.securityDetails,
    );
  }
}
