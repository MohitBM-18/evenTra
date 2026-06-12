// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import '../models/lost_found_model.dart';

class LostFoundProvider extends ChangeNotifier {
  final List<LostFoundItem> _items = [
    LostFoundItem(
      id: 'lf1',
      title: 'AirPods Pro Gen 2',
      description: 'Found a single right AirPods Pro inside the KE Auditorium under row G.',
      foundLocation: 'KE Auditorium',
      foundDate: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: null,
      contactInfo: 'Contact BCA Department office or Block Central reception.',
      status: 'Found',
      reportedBy: 'Mohit B M',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LostFoundItem(
      id: 'lf2',
      title: '65W OnePlus Charger',
      description: 'OnePlus black warp charger left plugged in near the podium.',
      foundLocation: 'MBA Seminar Hall',
      foundDate: DateTime.now().subtract(const Duration(hours: 4)),
      imageUrl: null,
      contactInfo: 'Contact Prof. Rajesh (MBA Block).',
      status: 'Found',
      reportedBy: 'Jane Doe',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  List<LostFoundItem> get items => _items;

  List<LostFoundItem> get activeFoundItems => _items.where((i) => i.status == 'Found').toList();

  void addItem(LostFoundItem item) {
    _items.add(item);
    notifyListeners();
  }

  void claimItem(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(status: 'Claimed');
      notifyListeners();
    }
  }
}
