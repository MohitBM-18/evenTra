import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auditorium_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class AuditoriumDetailScreen extends StatelessWidget {
  final String auditoriumId;

  const AuditoriumDetailScreen({super.key, required this.auditoriumId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditoriumProvider>(context);
    final auditorium = provider.getAuditoriumById(auditoriumId);

    if (auditorium == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Venue Details')),
        body: const Center(child: Text('Auditorium not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.borderColor(context),
                child: Image.network(
                  auditorium.imageUrl.isNotEmpty 
                      ? auditorium.imageUrl 
                      : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=500&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image_rounded, size: 64, color: Colors.black12)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          auditorium.venueName,
                          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: auditorium.isActive ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          auditorium.isActive ? 'Available' : 'Unavailable',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: auditorium.isActive ? AppTheme.success : AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(context, Icons.location_on_rounded, auditorium.blockName),
                      const SizedBox(width: 16),
                      _buildInfoChip(context, Icons.people_rounded, '${auditorium.capacity} Seats'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('About', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    auditorium.description,
                    style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: AppTheme.secondaryTextColor(context)),
                  ),
                  const SizedBox(height: 32),
                  Text('Facilities', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: auditorium.facilities.map((f) => AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.primaryColor(context)),
                          const SizedBox(width: 8),
                          Text(f, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  if (auditorium.inchargeName.isNotEmpty) ...[
                    Text('Venue Incharge', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        children: [
                          _buildDetailRow(context, Icons.person_rounded, 'Name', auditorium.inchargeName),
                          if (auditorium.inchargeEmail.isNotEmpty)
                            _buildDetailRow(context, Icons.email_rounded, 'Email', auditorium.inchargeEmail),
                          if (auditorium.inchargePhone.isNotEmpty)
                            _buildDetailRow(context, Icons.phone_rounded, 'Phone', auditorium.inchargePhone),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  PrimaryButton(
                    text: 'Book this Venue',
                    icon: Icons.event_available_rounded,
                    onPressed: auditorium.isActive ? () {
                      Navigator.pushNamed(
                        context,
                        Constants.bookingFormRoute,
                        arguments: auditorium,
                      );
                    } : null,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryTextColor(context)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 15, color: AppTheme.secondaryTextColor(context))),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor(context)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryTextColor(context))),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
