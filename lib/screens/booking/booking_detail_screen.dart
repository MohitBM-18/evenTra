import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';
import '../../models/enums.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    // Find booking
    final booking = bookingProvider.bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => bookingProvider.bookings.first,
    );

    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(booking.date);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Booking Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: StatusChip(status: booking.status, fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Approval Stepper Progress
          _buildApprovalTimeline(booking.approvalStage),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.eventName,
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  booking.eventDescription,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Event Details',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                ),
                const SizedBox(height: 12),
                _buildSimpleRow('Chief Guest/Speaker', booking.guestDetails.isEmpty ? 'Not Provided' : booking.guestDetails),
                const SizedBox(height: 8),
                _buildSimpleRow('Tech Setup', booking.techSetup.isEmpty ? 'Standard' : booking.techSetup),
                const SizedBox(height: 8),
                _buildSimpleRow('Security Plan', booking.securityDetails.isEmpty ? 'Not Required' : booking.securityDetails),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                _buildInfoRow(Icons.meeting_room, 'Venue', booking.auditoriumName),
                const Divider(height: 20),
                _buildInfoRow(Icons.calendar_today, 'Date', formattedDate),
                const Divider(height: 20),
                _buildInfoRow(Icons.access_time, 'Time', '${booking.startTime} - ${booking.endTime}'),
                const Divider(height: 20),
                _buildInfoRow(Icons.people, 'Attendees', '${booking.attendees} expected'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organizer & Purpose',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSimpleRow('Club/Dept', booking.clubOrDepartment),
                const SizedBox(height: 8),
                _buildSimpleRow('Purpose', booking.purpose),
                const SizedBox(height: 8),
                _buildSimpleRow('Requested By', booking.userName),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (booking.equipment.isNotEmpty)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Requested',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: booking.equipment.map((eq) => Chip(label: Text(eq))).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalTimeline(ApprovalStage currentStage) {
    if (currentStage == ApprovalStage.rejected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassDecoration().copyWith(
          border: Border.all(color: AppTheme.error.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: AppTheme.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Booking Request Rejected',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.error),
            ),
          ],
        ),
      );
    }

    final stages = [
      {'title': 'Submitted', 'stage': ApprovalStage.submitted},
      {'title': 'Coordinator', 'stage': ApprovalStage.coordinatorApproved},
      {'title': 'HOD', 'stage': ApprovalStage.hodApproved},
      {'title': 'In-Charge', 'stage': ApprovalStage.venueInChargeApproved},
    ];

    int currentIdx = stages.indexWhere((s) => s['stage'] == currentStage);
    if (currentIdx == -1) currentIdx = 0;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
            child: Text(
              'Approval Status Timeline',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (idx) {
              final stepStage = stages[idx]['stage'] as ApprovalStage;
              final title = stages[idx]['title'] as String;

              final isCompleted = idx <= currentIdx;
              final isCurrent = idx == currentIdx;

              final activeColor = stepStage == ApprovalStage.venueInChargeApproved ? AppTheme.success : AppTheme.primaryCyan;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: idx == 0
                                ? Colors.transparent
                                : (isCompleted ? activeColor : Colors.white10),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? activeColor.withOpacity(0.2) : Colors.transparent,
                            border: Border.all(
                              color: isCompleted ? activeColor : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted && !isCurrent
                                ? Icon(Icons.check, size: 14, color: activeColor)
                                : Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent ? activeColor : Colors.transparent,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: idx == stages.length - 1
                                ? Colors.transparent
                                : (idx < currentIdx ? activeColor : Colors.white10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? activeColor : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryCyan, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
