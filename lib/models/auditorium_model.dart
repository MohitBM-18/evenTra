import 'package:cloud_firestore/cloud_firestore.dart';

class AuditoriumModel {
  final String venueId;
  final String venueName;
  final String blockName;
  final String description;
  final int capacity;
  final String imageUrl;
  final String inchargeName;
  final String inchargeEmail;
  final String inchargePhone;
  final List<String> facilities;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AuditoriumModel({
    required this.venueId,
    required this.venueName,
    required this.blockName,
    required this.description,
    required this.capacity,
    required this.imageUrl,
    required this.inchargeName,
    required this.inchargeEmail,
    required this.inchargePhone,
    required this.facilities,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuditoriumModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AuditoriumModel(
      venueId: doc.id, // we use doc.id directly as venueId
      venueName: data['venueName'] ?? '',
      blockName: data['blockName'] ?? '',
      description: data['description'] ?? '',
      capacity: data['capacity'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      inchargeName: data['inchargeName'] ?? '',
      inchargeEmail: data['inchargeEmail'] ?? '',
      inchargePhone: data['inchargePhone'] ?? '',
      facilities: List<String>.from(data['facilities'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'venueName': venueName,
      'blockName': blockName,
      'description': description,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'inchargeName': inchargeName,
      'inchargeEmail': inchargeEmail,
      'inchargePhone': inchargePhone,
      'facilities': facilities,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AuditoriumModel copyWith({
    String? venueId,
    String? venueName,
    String? blockName,
    String? description,
    int? capacity,
    String? imageUrl,
    String? inchargeName,
    String? inchargeEmail,
    String? inchargePhone,
    List<String>? facilities,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuditoriumModel(
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      blockName: blockName ?? this.blockName,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      imageUrl: imageUrl ?? this.imageUrl,
      inchargeName: inchargeName ?? this.inchargeName,
      inchargeEmail: inchargeEmail ?? this.inchargeEmail,
      inchargePhone: inchargePhone ?? this.inchargePhone,
      facilities: facilities ?? this.facilities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
