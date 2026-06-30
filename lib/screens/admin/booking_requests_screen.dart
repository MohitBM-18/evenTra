import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/enums.dart';
import '../../models/booking_model.dart';
import '../../widgets/data_table_card.dart';
import '../../widgets/status_chip.dart';
import '../../utils/constants.dart';

class BookingRequestsScreen extends StatelessWidget {
  const BookingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    // Filter logic based on role
    List<BookingModel> requests = [];
    if (user.role == UserRole.superAdmin) {
      requests = bookingProvider.bookings; // Sees all
    } else if (user.role == UserRole.facultyCoordinator) {
      requests = bookingProvider.pendingFacultyBookings.where((b) => b.clubOrDepartment == user.department).toList();
    } else if (user.role == UserRole.hod) {
      requests = bookingProvider.pendingHodBookings.where((b) => b.clubOrDepartment == user.department).toList();
    } else if (user.role == UserRole.venueIncharge) {
      requests = bookingProvider.pendingVenueBookings; // Sees all pending venue
    }

    // Sort by most recent request first
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Requests'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: DataTableCard(
            title: 'Actionable Requests',
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Event')),
              DataColumn(label: Text('Venue')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: requests.map((booking) => DataRow(
              cells: [
                DataCell(Text(booking.bookingId, style: const TextStyle(fontSize: 12))),
                DataCell(Text(booking.eventName)),
                DataCell(Text(booking.auditoriumName)),
                DataCell(Text(DateFormat('MMM d, y').format(booking.date))),
                DataCell(StatusChip(status: booking.status)),
                DataCell(
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Constants.bookingDetailRoute, arguments: booking.id);
                    },
                    child: const Text('Review'),
                  )
                ),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }
}
