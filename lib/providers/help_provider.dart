// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import '../models/help_request_model.dart';

class HelpProvider extends ChangeNotifier {
  final List<HelpRequestModel> _requests = [
    HelpRequestModel(
      id: 'hr1',
      bookingId: 'b1',
      bookingName: 'Annual Tech Fest Opening',
      requestedBy: 'Mohit B M',
      items: ['Mic', 'Speaker'],
      chairCount: 0,
      additionalNotes: 'Need 2 extra wireless mics and a backup speaker.',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HelpRequestModel(
      id: 'hr2',
      bookingId: 'b4',
      bookingName: 'Cultural Night Rehearsal',
      requestedBy: 'John Smith',
      items: ['AC Remote', 'Chairs'],
      chairCount: 50,
      additionalNotes: 'We need 50 plastic chairs near the stage and the AC remote is missing.',
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<HelpRequestModel> get requests => _requests;

  List<HelpRequestModel> get pendingRequests => _requests.where((r) => r.status == 'Pending').toList();

  void createRequest(HelpRequestModel request) {
    _requests.add(request);
    notifyListeners();
  }

  void updateRequestStatus(String id, String status) {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(status: status);
      notifyListeners();
    }
  }
}
