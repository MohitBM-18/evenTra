// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String foundLocation; // e.g. KE Auditorium, MBA Seminar Hall
  final DateTime foundDate;
  final String? imageUrl; // Mock image URL or placeholder
  final String contactInfo;
  final String status; // 'Lost', 'Found', 'Claimed'
  final String reportedBy;
  final DateTime createdAt;

  LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.foundLocation,
    required this.foundDate,
    this.imageUrl,
    required this.contactInfo,
    this.status = 'Found',
    required this.reportedBy,
    required this.createdAt,
  });

  LostFoundItem copyWith({
    String? id,
    String? title,
    String? description,
    String? foundLocation,
    DateTime? foundDate,
    String? imageUrl,
    String? contactInfo,
    String? status,
    String? reportedBy,
    DateTime? createdAt,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      foundLocation: foundLocation ?? this.foundLocation,
      foundDate: foundDate ?? this.foundDate,
      imageUrl: imageUrl ?? this.imageUrl,
      contactInfo: contactInfo ?? this.contactInfo,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
