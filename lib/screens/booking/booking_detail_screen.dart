import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/enums.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/approval_timeline.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // We can't find by ID directly via a getter easily since bookings are streams.
    // Let's assume it's loaded in memory, otherwise might need a fallback.
    final bookingIndex = bookingProvider.bookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex == -1 || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: Text('Booking not found.')),
      );
    }

    final booking = bookingProvider.bookings[bookingIndex];
    final isOwner = booking.userId == user.id;
    final isApprover = user.role.canApproveBookings;
    final isSuperAdmin = user.role == UserRole.superAdmin;

    // Check if the current user can approve THIS specific booking stage
    bool canApproveNow = false;
    if (isApprover) {
      if (user.role == UserRole.facultyCoordinator && booking.status == BookingStatus.pendingFaculty) canApproveNow = true;
      if (user.role == UserRole.hod && booking.status == BookingStatus.pendingHod) canApproveNow = true;
      if (user.role == UserRole.venueIncharge && booking.status == BookingStatus.pendingVenue) canApproveNow = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(booking.bookingId),
        actions: [
          if (isOwner && booking.status.isPending)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
              tooltip: 'Cancel Request',
              onPressed: () => _confirmAction(context, 'Cancel', () {
                bookingProvider.cancelBooking(booking.id);
                Navigator.pop(context);
              }),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventName,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.auditoriumName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.primaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 24),
              
              // Key Details Grid
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildDetailRow(context, Icons.calendar_today_rounded, 'Date', DateFormat('EEEE, MMM d, y').format(booking.date)),
                    const Divider(height: 1),
                    _buildDetailRow(context, Icons.access_time_rounded, 'Time', '${booking.startTime} - ${booking.endTime}'),
                    const Divider(height: 1),
                    _buildDetailRow(context, Icons.category_rounded, 'Category', booking.eventCategory),
                    const Divider(height: 1),
                    _buildDetailRow(context, Icons.people_rounded, 'Expected Audience', '${booking.attendees} people'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text('Description', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppCard(
                child: Text(
                  booking.eventDescription,
                  style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppTheme.secondaryTextColor(context)),
                ),
              ),
              const SizedBox(height: 24),

              // Organizer Info
              Text('Organizer Info', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildDetailRow(context, Icons.person_rounded, 'Name', booking.organizerName),
                    const Divider(height: 1),
                    _buildDetailRow(context, Icons.phone_rounded, 'Contact', booking.organizerContact),
                    const Divider(height: 1),
                    _buildDetailRow(context, Icons.business_rounded, 'Department', booking.clubOrDepartment),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Requirements
              if (booking.equipment.isNotEmpty || booking.techSetup.isNotEmpty) ...[
                Text('Requirements', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking.equipment.isNotEmpty) ...[
                        Text('Equipment', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: booking.equipment.map((e) => Chip(
                            label: Text(e, style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )).toList(),
                        ),
                      ],
                      if (booking.equipment.isNotEmpty && booking.techSetup.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1),
                        ),
                      if (booking.techSetup.isNotEmpty) ...[
                        Text('Tech Setup Notes', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          booking.techSetup,
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryTextColor(context)),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Approval Timeline
              Text('Approval Timeline', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              AppCard(
                child: ApprovalTimeline(history: booking.approvalHistory),
              ),
              const SizedBox(height: 48),

              // Approver Action Buttons
              if (canApproveNow) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showActionDialog(context, bookingProvider, booking, user, 'Reject'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: const BorderSide(color: AppTheme.error)),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showActionDialog(context, bookingProvider, booking, user, 'Request Changes'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.warning, side: const BorderSide(color: AppTheme.warning)),
                        child: const Text('Changes'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Approve Request',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => _showActionDialog(context, bookingProvider, booking, user, 'Approve'),
                ),
                const SizedBox(height: 48),
              ],

              // Super Admin Overrides
              if (isSuperAdmin && booking.status.isPending) ...[
                const Divider(),
                const SizedBox(height: 16),
                Text('Super Admin Override', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Force Reject',
                        isDestructive: true,
                        height: 40,
                        onPressed: () => _confirmAction(context, 'Force Reject', () {
                          bookingProvider.forceRejectBooking(booking.id, user.name);
                          Navigator.pop(context);
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Force Approve',
                        height: 40,
                        onPressed: () => _confirmAction(context, 'Force Approve', () {
                          bookingProvider.forceApproveBooking(booking.id, user.name);
                          Navigator.pop(context);
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryTextColor(context)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(color: AppTheme.secondaryTextColor(context), fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String actionName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $actionName'),
        content: Text('Are you sure you want to $actionName this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: onConfirm,
            child: Text('Confirm', style: TextStyle(color: actionName.contains('Reject') || actionName.contains('Cancel') ? AppTheme.error : AppTheme.primaryPurple)),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, BookingProvider provider, BookingModel booking, UserModel user, String actionType) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionType Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add an optional comment:'),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Looks good to me, or please update the expected audience.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          PrimaryButton(
            width: 100,
            height: 40,
            text: 'Submit',
            isDestructive: actionType == 'Reject',
            onPressed: () {
              final comment = commentController.text.trim();
              if (actionType == 'Approve') {
                provider.approveBooking(booking.id, user.id, user.name, user.role, comment: comment);
              } else if (actionType == 'Reject') {
                provider.rejectBooking(booking.id, user.id, user.name, user.role, comment);
              } else if (actionType == 'Request Changes') {
                provider.requestChanges(booking.id, user.id, user.name, user.role, comment);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
