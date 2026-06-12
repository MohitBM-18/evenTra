// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

class InchargeModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String designation;
  final String assignedVenue;

  InchargeModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.designation,
    required this.assignedVenue,
  });

  InchargeModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? designation,
    String? assignedVenue,
  }) {
    return InchargeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      assignedVenue: assignedVenue ?? this.assignedVenue,
    );
  }
}
