import 'package:flutter/material.dart';
import '../models/auditorium_model.dart';
import '../data/mock_data.dart';

class AuditoriumProvider extends ChangeNotifier {
  final List<AuditoriumModel> _auditoriums = MockData.auditoriums;
  String? _selectedBlock;
  RangeValues _capacityRange = const RangeValues(0, 1000);
  final List<String> _selectedFacilities = [];

  List<AuditoriumModel> get auditoriums => _auditoriums;
  String? get selectedBlock => _selectedBlock;
  RangeValues get capacityRange => _capacityRange;
  List<String> get selectedFacilities => _selectedFacilities;

  List<AuditoriumModel> get filteredAuditoriums {
    return _auditoriums.where((audi) {
      final matchesBlock = _selectedBlock == null || _selectedBlock == 'All' || audi.blockName == _selectedBlock;
      final matchesCapacity = audi.capacity >= _capacityRange.start && audi.capacity <= _capacityRange.end;
      final matchesFacilities = _selectedFacilities.isEmpty ||
          _selectedFacilities.every((facility) => audi.facilities.contains(facility));

      return matchesBlock && matchesCapacity && matchesFacilities;
    }).toList();
  }

  AuditoriumModel? getAuditoriumById(String id) {
    try {
      return _auditoriums.firstWhere((audi) => audi.id == id);
    } catch (e) {
      return null;
    }
  }

  void setBlockFilter(String? block) {
    _selectedBlock = block;
    notifyListeners();
  }

  void setCapacityRange(RangeValues range) {
    _capacityRange = range;
    notifyListeners();
  }

  void toggleFacilityFilter(String facility) {
    if (_selectedFacilities.contains(facility)) {
      _selectedFacilities.remove(facility);
    } else {
      _selectedFacilities.add(facility);
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedBlock = null;
    _capacityRange = const RangeValues(0, 1000);
    _selectedFacilities.clear();
    notifyListeners();
  }
}
