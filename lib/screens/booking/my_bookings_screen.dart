import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';
import '../../utils/constants.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookings = bookingProvider.userBookings(user?.id ?? 'u1');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'My Bookings',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookings.isEmpty
                  ? Center(
                      child: Text(
                        'You haven\'t made any bookings yet.',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, idx) {
                        final booking = bookings[idx];
                        final formattedDate = DateFormat('EEE, d MMM').format(booking.date);

                        return GlassCard(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constants.bookingDetailRoute,
                              arguments: booking.id,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.eventName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  StatusChip(status: booking.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.meeting_room, size: 16, color: AppTheme.primaryCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.auditoriumName,
                                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$formattedDate • ${booking.startTime} - ${booking.endTime}',
                                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                                  ),
                                ],
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
    );
  }
}
