// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/lost_found_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/lost_found_model.dart';
import '../../widgets/gradient_button.dart';

class AddLostFoundScreen extends StatefulWidget {
  const AddLostFoundScreen({super.key});

  @override
  State<AddLostFoundScreen> createState() => _AddLostFoundScreenState();
}

class _AddLostFoundScreenState extends State<AddLostFoundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isPhotoAttached = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final provider = Provider.of<LostFoundProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Report Found Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Add Item Details',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide clear details so the owner can match and claim it.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Item Name / Title',
                hintText: 'e.g. AirPods Pro Charger Case',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Where was it found?',
                hintText: 'e.g. KE Auditorium Row F, MBA Seminar Hall',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Item Description',
                hintText: 'Color, identifying marks, condition, etc.',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact / Claim Office Info',
                hintText: 'e.g. Leave at Block 4 reception desk',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            // Mock Photo Upload Trigger
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPhotoAttached = !_isPhotoAttached;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isPhotoAttached ? 'Mock Photo uploaded successfully!' : 'Photo detached.'),
                  ),
                );
              },
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPhotoAttached ? AppTheme.success : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: _isPhotoAttached
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 48),
                            const SizedBox(height: 8),
                            Text('Photo Attached!', style: GoogleFonts.inter(color: AppTheme.success, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryCyan, size: 48),
                            const SizedBox(height: 8),
                            Text('Click to Upload/Take Photo', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Publish Found Item',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newItem = LostFoundItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    description: _descController.text,
                    foundLocation: _locationController.text,
                    foundDate: DateTime.now(),
                    contactInfo: _contactController.text,
                    reportedBy: user?.name ?? 'Organizer',
                    createdAt: DateTime.now(),
                  );

                  provider.addItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item successfully posted to Lost & Found board!')),
                  );
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
