import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final stats = bookingProvider.getBookingStats();
    final pendingCount = stats['pendingCount'] ?? 0;
    final totalCount = stats['totalBookings'] ?? 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal',
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Christ University Venue Management',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Icon(Icons.admin_panel_settings, size: 36, color: AppTheme.primaryCyan),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Bookings', totalCount.toString(), AppTheme.primaryPurple),
              _buildStatCard('Pending Requests', pendingCount.toString(), AppTheme.pending),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            tileColor: AppTheme.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.pending_actions, color: AppTheme.pending),
            title: const Text('Manage Booking Requests'),
            subtitle: Text('$pendingCount requests need review'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, Constants.bookingRequestsRoute);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Analytics',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auditorium Booking Distribution', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Simple placeholder bar chart
                _buildBarRow('KE Auditorium', 0.8),
                _buildBarRow('Main Auditorium', 0.6),
                _buildBarRow('Mini Auditorium', 0.4),
                _buildBarRow('MBA Seminar Hall', 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      decoration: AppTheme.glassDecoration().copyWith(
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBarRow(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12)),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
