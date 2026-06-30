import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/auditorium_model.dart';

class AuditoriumProvider extends ChangeNotifier {
  List<AuditoriumModel> _auditoriums = [];
  String? _selectedBlock;
  RangeValues _capacityRange = const RangeValues(0, 1000);
  final List<String> _selectedFacilities = [];
  bool _isLoaded = false;

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

  Future<void> loadVenues() async {
    if (_isLoaded) return;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('venues').get();
      _auditoriums = snapshot.docs.map((doc) => AuditoriumModel.fromFirestore(doc)).toList();
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading venues: $e');
    }
  }

  AuditoriumModel? getAuditoriumById(String id) {
    try {
      return _auditoriums.firstWhere((audi) => audi.venueId == id);
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

  Future<String> uploadVenueImage(File imageFile, String venueName) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('venues')
          .child('${DateTime.now().millisecondsSinceEpoch}_$venueName.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('Image upload failed');
    }
  }

  Future<void> createVenue(AuditoriumModel audi) async {
    try {
      final data = audi.toFirestore();
      // Remove venueId since Firestore auto-generates it
      data.remove('venueId');
      
      final docRef = await FirebaseFirestore.instance.collection('venues').add(data);
      _auditoriums.add(audi.copyWith(venueId: docRef.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding auditorium: $e');
      throw Exception('Failed to create venue');
    }
  }

  Future<void> updateVenue(String id, AuditoriumModel updated) async {
    try {
      final data = updated.toFirestore();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await FirebaseFirestore.instance.collection('venues').doc(id).update(data);
      final idx = _auditoriums.indexWhere((a) => a.venueId == id);
      if (idx != -1) {
        _auditoriums[idx] = updated.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating auditorium: $e');
      throw Exception('Failed to update venue');
    }
  }

  Future<void> deleteVenue(String id) async {
    try {
      await FirebaseFirestore.instance.collection('venues').doc(id).delete();
      _auditoriums.removeWhere((a) => a.venueId == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting auditorium: $e');
      throw Exception('Failed to delete venue');
    }
  }

  Future<void> toggleAvailability(String id) async {
    final idx = _auditoriums.indexWhere((a) => a.venueId == id);
    if (idx != -1) {
      final newStatus = !_auditoriums[idx].isActive;
      try {
        await FirebaseFirestore.instance.collection('venues').doc(id).update({
          'isActive': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _auditoriums[idx] = _auditoriums[idx].copyWith(
          isActive: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error toggling availability: $e');
        throw Exception('Failed to toggle status');
      }
    }
  }
}
