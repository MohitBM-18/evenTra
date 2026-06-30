import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/empty_state.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    final allBookings = bookingProvider.userBookings(user.id);
    
    // Search filter
    final filteredBookings = allBookings.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.eventName.toLowerCase().contains(_searchQuery) ||
             b.auditoriumName.toLowerCase().contains(_searchQuery) ||
             b.bookingId.toLowerCase().contains(_searchQuery);
    }).toList();

    // Tab filters
    final upcomingBookings = filteredBookings.where((b) => 
      b.date.isAfter(DateTime.now().subtract(const Duration(days: 1))) && 
      (b.status == BookingStatus.confirmed || b.status.isPending)
    ).toList();
    
    final pastBookings = filteredBookings.where((b) => 
      b.date.isBefore(DateTime.now().subtract(const Duration(days: 1))) || 
      b.status == BookingStatus.completed
    ).toList();
    
    final actionRequiredBookings = filteredBookings.where((b) => 
      b.status == BookingStatus.changesRequested || b.status == BookingStatus.rejected
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Action Required'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by event, venue, or ID...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(upcomingBookings),
                _buildList(actionRequiredBookings),
                _buildList(pastBookings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No Bookings Found',
        message: _searchQuery.isNotEmpty 
            ? 'Try adjusting your search terms.'
            : 'You have no bookings in this category.',
      );
    }

    // Sort by date closest to today first
    bookings.sort((a, b) => a.date.compareTo(b.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return AppCard(
          onTap: () {
            // Need to implement booking detail screen route
            Navigator.pushNamed(context, '/booking_detail', arguments: booking.id);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.auditoriumName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.secondaryTextColor(context)),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, y').format(booking.date),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.secondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded, size: 14, color: AppTheme.secondaryTextColor(context)),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.startTime} - ${booking.endTime}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.secondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    booking.bookingId,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.borderColor(context), // very subtle
                    ),
                  ),
                ],
              ),
              if (booking.approvalStage != ApprovalStage.venueApproved && booking.status.isPending) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _calculateProgress(booking.approvalStage),
                  backgroundColor: AppTheme.borderColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor(context)),
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.approvalStage.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.primaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _calculateProgress(ApprovalStage stage) {
    switch (stage) {
      case ApprovalStage.submitted: return 0.25;
      case ApprovalStage.facultyApproved: return 0.50;
      case ApprovalStage.hodApproved: return 0.75;
      case ApprovalStage.venueApproved: return 1.0;
      default: return 0.0;
    }
  }
}
