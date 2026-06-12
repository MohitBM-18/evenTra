import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/glass_card.dart';

import '../../models/enums.dart';

class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final pendingRequests = bookingProvider.pendingBookings;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Booking Requests', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: pendingRequests.isEmpty
          ? Center(
              child: Text(
                'No pending booking requests.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingRequests.length,
              itemBuilder: (context, idx) {
                final req = pendingRequests[idx];
                
                String approveBtnText = 'Approve';
                if (req.approvalStage == ApprovalStage.submitted) {
                  approveBtnText = 'Approve as Coordinator';
                } else if (req.approvalStage == ApprovalStage.coordinatorApproved) {
                  approveBtnText = 'Approve as HOD';
                } else if (req.approvalStage == ApprovalStage.hodApproved) {
                  approveBtnText = 'Final Approve (In-Charge)';
                }

                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              req.eventName,
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            req.clubOrDepartment,
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stage: ${req.approvalStage.displayName}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryCyan, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Venue: ${req.auditoriumName}', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      Text('Date: ${req.date.toLocal().toString().split(' ')[0]}', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      Text('Time: ${req.startTime} - ${req.endTime}', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      Text('Organizer: ${req.userName}', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      if (req.guestDetails.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Chief Guest: ${req.guestDetails}', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              bookingProvider.rejectBooking(req.id, 'Rejected by Admin');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking rejected.')),
                              );
                            },
                            child: const Text('Reject', style: TextStyle(color: AppTheme.error)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              bookingProvider.approveBooking(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booking progressed: ${req.approvalStage.displayName}')),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                            child: Text(approveBtnText),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
