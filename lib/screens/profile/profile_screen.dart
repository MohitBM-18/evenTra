import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Center(child: Text('Not logged in'));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Profile', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          
          // User Info Card
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.primaryColor(context).withOpacity(0.1),
                  backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                  child: user.profileImageUrl == null 
                    ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U', style: TextStyle(fontSize: 24, color: AppTheme.primaryColor(context), fontWeight: FontWeight.bold))
                    : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.secondaryTextColor(context))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(user.role.displayName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor(context))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings Section
          Text('Preferences', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Dark Mode', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(),
                  activeColor: AppTheme.primaryColor(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_rounded),
                  title: Text('Notification Settings', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    // Open device settings or custom screen
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Support Section
          Text('Support', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_rounded),
                  title: Text('Help & Support', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, '/help_requests'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: Text('Privacy Policy', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Logout Button
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                final bp = Provider.of<BookingProvider>(context, listen: false);
                final np = Provider.of<NotificationProvider>(context, listen: false);
                bp.clearBookings();
                np.clearUser();
                authProvider.logout();
                Navigator.pushReplacementNamed(context, Constants.loginRoute);
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: Text('Log Out', style: GoogleFonts.inter(color: AppTheme.error, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'evenTra v1.0.0\nChrist University',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryTextColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
