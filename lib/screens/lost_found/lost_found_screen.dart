// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/lost_found_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/constants.dart';

class LostFoundScreen extends StatelessWidget {
  const LostFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lostFoundProvider = Provider.of<LostFoundProvider>(context);
    final items = lostFoundProvider.activeFoundItems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Lost & Found', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Found Items on Campus',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'If you lost your airpods, charger, keychains or anything, check if organizers found them.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No reported items at the moment.',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        final formattedDate = DateFormat('d MMM yyyy').format(item.foundDate);

                        return GlassCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.accentGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.help_center_outlined, color: Colors.white, size: 36),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Location: ${item.foundLocation}',
                                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primaryCyan),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Found on: $formattedDate',
                                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(item.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Description: ${item.description}'),
                                                const SizedBox(height: 12),
                                                Text('How to Claim: ${item.contactInfo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  lostFoundProvider.claimItem(item.id);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Item marked as claimed!')),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                                child: const Text('Mark as Claimed'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Details / Claim'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_lost_found');
        },
        label: const Text('Report Found Item'),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }
}
