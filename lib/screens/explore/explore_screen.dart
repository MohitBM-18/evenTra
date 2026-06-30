import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auditorium_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/app_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuditoriumProvider>(context, listen: false).loadVenues();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audiProvider = Provider.of<AuditoriumProvider>(context);
    final allVenues = audiProvider.auditoriums;

    final filteredVenues = allVenues.where((v) {
      if (_searchQuery.isEmpty) return true;
      return v.venueName.toLowerCase().contains(_searchQuery) ||
             v.blockName.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Open filter modal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by venue name or block...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: filteredVenues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final venue = filteredVenues[index];
                return AppCard(
                  onTap: () {
                    Navigator.pushNamed(context, Constants.auditoriumDetailRoute, arguments: venue.venueId);
                  },
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image placeholder
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor(context),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMd)),
                          child: Image.network(
                            venue.imageUrl.isNotEmpty 
                                ? venue.imageUrl 
                                : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=500&fit=crop',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image_rounded, size: 48, color: AppTheme.secondaryTextColor(context).withValues(alpha: 0.3)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    venue.venueName,
                                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: venue.isActive ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    venue.isActive ? 'Available' : 'Unavailable',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: venue.isActive ? AppTheme.success : AppTheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: AppTheme.secondaryTextColor(context)),
                                const SizedBox(width: 4),
                                Text(
                                  venue.blockName,
                                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.secondaryTextColor(context)),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.people_rounded, size: 16, color: AppTheme.secondaryTextColor(context)),
                                const SizedBox(width: 4),
                                Text(
                                  '${venue.capacity}',
                                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.secondaryTextColor(context)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: venue.facilities.take(3).map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.borderColor(context)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(f, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryTextColor(context))),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
