import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auditorium_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/constants.dart';
import '../../models/enums.dart';

class AuditoriumDetailScreen extends StatelessWidget {
  final String auditoriumId;

  const AuditoriumDetailScreen({super.key, required this.auditoriumId});

  @override
  Widget build(BuildContext context) {
    final audiProvider = Provider.of<AuditoriumProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final audi = audiProvider.getAuditoriumById(auditoriumId);

    if (audi == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: Text('Auditorium not found.')),
      );
    }

    final recentBookings = bookingProvider.getBookingsForAuditorium(auditoriumId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(audi.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                ),
                child: Center(
                  child: Icon(Icons.meeting_room, size: 80, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryCyan, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${audi.blockName} • ${audi.floor}',
                                style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${audi.capacity} Capacity',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audi.description,
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Facilities Available',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: audi.facilities.map((fac) {
                      return Chip(
                        label: Text(fac),
                        backgroundColor: AppTheme.cardBg,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Bookings',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (recentBookings.isEmpty)
                    Text('No current bookings for this venue.', style: GoogleFonts.inter(color: AppTheme.textSecondary))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentBookings.length,
                      itemBuilder: (context, index) {
                        final booking = recentBookings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(booking.eventName),
                            subtitle: Text('${booking.startTime} - ${booking.endTime} (${booking.clubOrDepartment})'),
                            trailing: Text(booking.status.displayName, style: TextStyle(
                              color: booking.status == BookingStatus.approved ? AppTheme.success : AppTheme.pending
                            )),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: AppTheme.background,
        padding: const EdgeInsets.all(16.0),
        child: GradientButton(
          text: 'Request Booking',
          onPressed: () {
            Navigator.pushNamed(
              context,
              Constants.bookingFormRoute,
              arguments: auditoriumId,
            );
          },
        ),
      ),
    );
  }
}
