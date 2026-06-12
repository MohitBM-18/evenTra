import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/auditorium_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';
import '../../models/enums.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/constants.dart';

class BookingFormScreen extends StatefulWidget {
  final String auditoriumId;

  const BookingFormScreen({super.key, required this.auditoriumId});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _descController = TextEditingController();
  final _attendeesController = TextEditingController();
  final _clubController = TextEditingController();
  final _guestDetailsController = TextEditingController();
  final _techSetupController = TextEditingController();
  final _securityController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  String _selectedPurpose = 'Academic';
  final List<String> _selectedEquipment = [];

  final List<String> _purposes = ['Academic', 'Cultural', 'Technical', 'Sports', 'Meeting', 'Workshop', 'Other'];
  final List<String> _equipmentOptions = ['Projector', 'Microphone', 'Speakers', 'Whiteboard', 'Laptop', 'Podium'];

  @override
  Widget build(BuildContext context) {
    final audi = Provider.of<AuditoriumProvider>(context).getAuditoriumById(widget.auditoriumId);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final bookingProvider = Provider.of<BookingProvider>(context);

    if (audi == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(child: Text('Auditorium not found.')),
      );
    }

    final formattedDate = DateFormat('EEE, d MMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Book Venue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(audi.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${audi.blockName} • Max Capacity: ${audi.capacity}', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clubController,
              decoration: const InputDecoration(labelText: 'Department / Club Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPurpose,
              decoration: const InputDecoration(labelText: 'Purpose'),
              items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPurpose = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Brief Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _attendeesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Expected Attendees'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Required Event Details (Prior to Approval)',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestDetailsController,
              decoration: const InputDecoration(
                labelText: 'Chief Guest / Speaker Details',
                hintText: 'Name, Designation, Organization...',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required to process approvals' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _techSetupController,
              decoration: const InputDecoration(
                labelText: 'Stage & Technical Setup Requirements',
                hintText: 'e.g. Sound levels check, dual projection, lapels...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _securityController,
              decoration: const InputDecoration(
                labelText: 'Crowd Control & Security Plan',
                hintText: 'e.g. 5 volunteers stationed, barricades needed...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            // Date Picker
            ListTile(
              title: const Text('Event Date'),
              subtitle: Text(formattedDate),
              trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryCyan),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const Divider(),
            // Time Pickers
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Text('Equipment Required', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _equipmentOptions.map((eq) {
                final isSelected = _selectedEquipment.contains(eq);
                return FilterChip(
                  label: Text(eq),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedEquipment.add(eq);
                      } else {
                        _selectedEquipment.remove(eq);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: 'Submit Request',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newBooking = BookingModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    auditoriumId: widget.auditoriumId,
                    auditoriumName: audi.name,
                    userId: user?.id ?? 'u1',
                    userName: user?.name ?? 'Anonymous',
                    eventName: _eventNameController.text,
                    eventDescription: _descController.text,
                    date: _selectedDate,
                    startTime: _startTime.format(context),
                    endTime: _endTime.format(context),
                    status: BookingStatus.pending,
                    approvalStage: ApprovalStage.submitted,
                    attendees: int.tryParse(_attendeesController.text) ?? 50,
                    equipment: _selectedEquipment,
                    clubOrDepartment: _clubController.text,
                    purpose: _selectedPurpose,
                    createdAt: DateTime.now(),
                    guestDetails: _guestDetailsController.text,
                    techSetup: _techSetupController.text,
                    securityDetails: _securityController.text,
                  );

                  bookingProvider.createBooking(newBooking);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request submitted successfully!')),
                  );
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
