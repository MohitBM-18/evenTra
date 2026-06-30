import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final stats = bookingProvider.getBookingStats();
    final pendingCount = stats['pendingCount'] ?? 0;
    final userRole = authProvider.currentUser?.role;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal',
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage approvals & venues',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.secondaryTextColor(context)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.admin_panel_settings_rounded, size: 28, color: AppTheme.primaryColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Total', stats['totalBookings'].toString(), AppTheme.info)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(context, 'Pending', pendingCount.toString(), AppTheme.warning)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Confirmed', stats['confirmedCount'].toString(), AppTheme.success)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(context, 'Rejected', stats['rejectedCount'].toString(), AppTheme.error)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Management', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildActionTile(
            context: context,
            title: 'Manage Requests',
            subtitle: '$pendingCount pending approvals across stages',
            icon: Icons.pending_actions_rounded,
            color: AppTheme.warning,
            onTap: () => Navigator.pushNamed(context, Constants.bookingRequestsRoute),
          ),
          if (authProvider.canEditIncharges) ...[
            const SizedBox(height: 32),
            Text('Super Admin', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.warning)),
            const SizedBox(height: 16),
            _buildActionTile(
              context: context,
              title: 'Manage Staff Roles',
              subtitle: 'Assign HODs and Venue Incharges',
              icon: Icons.people_alt_rounded,
              color: AppTheme.info,
              onTap: () => Navigator.pushNamed(context, '/manage_incharges'),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context: context,
              title: 'Manage Venues',
              subtitle: 'Add/edit auditoriums and capacities',
              icon: Icons.apartment_rounded,
              color: AppTheme.primaryColor(context),
              onTap: () => Navigator.pushNamed(context, '/manage_auditoriums'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.secondaryTextColor(context))),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryTextColor(context))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.secondaryTextColor(context)),
        ],
      ),
    );
  }
}
