// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

class HelpRequestModel {
  final String id;
  final String bookingId;
  final String bookingName;
  final String requestedBy;
  final List<String> items; // mic, chair, ac remote, speaker, etc.
  final int chairCount;
  final String additionalNotes;
  final String status; // 'Pending', 'In Progress', 'Resolved'
  final DateTime createdAt;

  HelpRequestModel({
    required this.id,
    required this.bookingId,
    required this.bookingName,
    required this.requestedBy,
    required this.items,
    this.chairCount = 0,
    required this.additionalNotes,
    this.status = 'Pending',
    required this.createdAt,
  });

  HelpRequestModel copyWith({
    String? id,
    String? bookingId,
    String? bookingName,
    String? requestedBy,
    List<String>? items,
    int? chairCount,
    String? additionalNotes,
    String? status,
    DateTime? createdAt,
  }) {
    return HelpRequestModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      bookingName: bookingName ?? this.bookingName,
      requestedBy: requestedBy ?? this.requestedBy,
      items: items ?? this.items,
      chairCount: chairCount ?? this.chairCount,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
