import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auditorium_provider.dart';
import '../../widgets/glass_card.dart';
import '../../utils/constants.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditoriumProvider>(context);
    final auditoriums = provider.filteredAuditoriums;

    // A list of mock blocks to filter by
    final blocks = ['All', 'Central Block', 'Main Block', 'MBA Block', 'Science Block', 'Library Block', 'Dharmaram Block', 'Block 1'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'Explore Venues',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search auditoriums...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.cardBg,
              ),
              onChanged: (val) {
                // In a real app we'd hook up text search filter
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: blocks.length,
                itemBuilder: (context, idx) {
                  final block = blocks[idx];
                  final isSelected = provider.selectedBlock == block || (provider.selectedBlock == null && block == 'All');
                  return GestureDetector(
                    onTap: () {
                      provider.setBlockFilter(block == 'All' ? null : block);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: isSelected
                          ? AppTheme.gradientDecoration(radius: 20)
                          : AppTheme.glassDecoration(radius: 20),
                      child: Center(
                        child: Text(
                          block,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: auditoriums.isEmpty
                  ? Center(
                      child: Text(
                        'No venues match the selected filters.',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: auditoriums.length,
                      itemBuilder: (context, idx) {
                        final audi = auditoriums[idx];
                        return GlassCard(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Constants.auditoriumDetailRoute,
                              arguments: audi.id,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: AppTheme.accentGradient,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${audi.capacity} seats',
                                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                audi.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: AppTheme.primaryCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${audi.blockName} • ${audi.floor}',
                                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: audi.facilities.map((fac) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      fac,
                                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                                    ),
                                  );
                                }).toList(),
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
