// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import '../models/incharge_model.dart';

class InchargeProvider extends ChangeNotifier {
  final List<InchargeModel> _incharges = [
    InchargeModel(
      id: 'ic1',
      name: 'Mr. Antony Raj',
      phone: '+91 98765 43210',
      email: 'antony.raj@christuniversity.in',
      designation: 'Auditorium General Manager',
      assignedVenue: 'KE Auditorium',
    ),
    InchargeModel(
      id: 'ic2',
      name: 'Prof. Rajesh Kumar',
      phone: '+91 91234 56789',
      email: 'rajesh.kumar@christuniversity.in',
      designation: 'MBA Block Venue In-charge',
      assignedVenue: 'MBA Seminar Hall',
    ),
    InchargeModel(
      id: 'ic3',
      name: 'Dr. Vinay M.',
      phone: '+91 94480 12345',
      email: 'vinay.m@christuniversity.in',
      designation: 'Science Block Coordinator',
      assignedVenue: 'BCA Lab Auditorium',
    ),
    InchargeModel(
      id: 'ic4',
      name: 'Mrs. Mary D\'Souza',
      phone: '+91 98450 98765',
      email: 'mary.dsouza@christuniversity.in',
      designation: 'Library Hall Supervisor',
      assignedVenue: 'Central Library Hall',
    ),
    InchargeModel(
      id: 'ic5',
      name: 'Brother Sunny',
      phone: '+91 97412 34567',
      email: 'sunny.cmi@christuniversity.in',
      designation: 'Dharmaram Venue Manager',
      assignedVenue: 'Dharmaram Auditorium',
    ),
  ];

  List<InchargeModel> get incharges => _incharges;

  void addIncharge(InchargeModel incharge) {
    _incharges.add(incharge);
    notifyListeners();
  }

  void updateIncharge(String id, InchargeModel updated) {
    final idx = _incharges.indexWhere((ic) => ic.id == id);
    if (idx != -1) {
      _incharges[idx] = updated;
      notifyListeners();
    }
  }

  void deleteIncharge(String id) {
    _incharges.removeWhere((ic) => ic.id == id);
    notifyListeners();
  }
}
