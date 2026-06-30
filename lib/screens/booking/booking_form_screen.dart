import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/auditorium_model.dart';
import '../../models/booking_model.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auditorium_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/form_field_wrapper.dart';

class BookingFormScreen extends StatefulWidget {
  final AuditoriumModel auditorium;

  const BookingFormScreen({super.key, required this.auditorium});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _audienceController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _organizerContactController = TextEditingController();
  final _techSetupController = TextEditingController();
  
  // State
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCategory = 'Academic';
  String _selectedDepartment = '';
  late String _selectedAuditoriumId;
  final List<String> _selectedEquipment = [];
  
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Academic', 'Cultural', 'Technical', 'Sports', 'Workshop', 'Seminar', 'Other'
  ];

  final List<String> _availableEquipment = [
    'Projector', 'Microphone', 'Speakers', 'Whiteboard', 'Laptop', 'Extension Board', 'Podium', 'Stage Lights'
  ];

  @override
  void initState() {
    super.initState();
    _selectedAuditoriumId = widget.auditorium.venueId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        _selectedDepartment = authProvider.currentUser!.department;
        _organizerNameController.text = authProvider.currentUser!.name;
        _organizerContactController.text = authProvider.currentUser!.phone;
      }
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescController.dispose();
    _audienceController.dispose();
    _organizerNameController.dispose();
    _organizerContactController.dispose();
    _techSetupController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), // Cannot be in the past
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart 
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 10, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  bool _isTimeValid() {
    if (_startTime == null || _endTime == null) return false;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    return endMinutes > startMinutes;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      _showError('Please select a date.');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Please select start and end times.');
      return;
    }
    if (!_isTimeValid()) {
      _showError('End time must be after start time.');
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      _showError('You must be logged in.');
      return;
    }

    setState(() { _isSubmitting = true; });

    // Conflict Check
    final isAvailable = bookingProvider.isSlotAvailable(
      _selectedAuditoriumId,
      _selectedDate!,
      _formatTime(_startTime),
      _formatTime(_endTime),
    );

    if (!isAvailable) {
      setState(() { _isSubmitting = false; });
      _showError('The venue is already booked or has a pending request for this time slot. Please choose another time or venue.');
      return;
    }

    final newBooking = BookingModel(
      id: '', // Will be assigned by Firestore
      bookingId: BookingModel.generateBookingId(),
      auditoriumId: _selectedAuditoriumId,
      auditoriumName: widget.auditorium.venueName, // If dropdown changes this, need to update
      userId: user.id,
      userName: user.name,
      userRole: user.role.displayName,
      eventName: _eventNameController.text,
      eventDescription: _eventDescController.text,
      eventCategory: _selectedCategory,
      date: _selectedDate!,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      status: BookingStatus.pendingFaculty,
      approvalStage: ApprovalStage.submitted,
      attendees: int.tryParse(_audienceController.text) ?? 0,
      equipment: _selectedEquipment,
      clubOrDepartment: _selectedDepartment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      organizerName: _organizerNameController.text,
      organizerContact: _organizerContactController.text,
      techSetup: _techSetupController.text,
    );

    await bookingProvider.createBooking(newBooking);

    if (mounted) {
      setState(() { _isSubmitting = false; });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking request submitted successfully.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audiProvider = Provider.of<AuditoriumProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking Request'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Venue & Time',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    FormFieldWrapper(
                      label: 'Venue',
                      isRequired: true,
                      child: DropdownButtonFormField<String>(
                        value: _selectedAuditoriumId,
                        isExpanded: true,
                        items: audiProvider.auditoriums.map((audi) {
                          return DropdownMenuItem(
                            value: audi.venueId,
                            child: Text(audi.venueName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAuditoriumId = val);
                        },
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Date',
                      isRequired: true,
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(
                            _selectedDate == null 
                              ? 'Select Date' 
                              : DateFormat('EEEE, MMM d, y').format(_selectedDate!),
                            style: GoogleFonts.inter(
                              color: _selectedDate == null ? AppTheme.secondaryTextColor(context) : AppTheme.textColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FormFieldWrapper(
                            label: 'Start Time',
                            isRequired: true,
                            child: InkWell(
                              onTap: () => _selectTime(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time_rounded)),
                                child: Text(
                                  _startTime == null ? 'Start' : _formatTime(_startTime),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormFieldWrapper(
                            label: 'End Time',
                            isRequired: true,
                            child: InkWell(
                              onTap: () => _selectTime(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time_rounded)),
                                child: Text(
                                  _endTime == null ? 'End' : _formatTime(_endTime),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Details',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    FormFieldWrapper(
                      label: 'Event Name',
                      isRequired: true,
                      child: TextFormField(
                        controller: _eventNameController,
                        decoration: const InputDecoration(hintText: 'e.g. Annual Tech Symposium'),
                        validator: (value) {
                          if (value == null || value.trim().length < 5) {
                            return 'Event name must be at least 5 characters.';
                          }
                          return null;
                        },
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Event Category',
                      isRequired: true,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Expected Audience',
                      isRequired: true,
                      child: TextFormField(
                        controller: _audienceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 150'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          final num = int.tryParse(value);
                          if (num == null || num <= 0) return 'Must be greater than 0';
                          return null;
                        },
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Description',
                      isRequired: true,
                      child: TextFormField(
                        controller: _eventDescController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Provide details about the event purpose, target audience, and activities.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 20) {
                            return 'Description must be at least 20 characters.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organizer Information',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    FormFieldWrapper(
                      label: 'Organizer Name',
                      isRequired: true,
                      child: TextFormField(
                        controller: _organizerNameController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Contact Number',
                      isRequired: true,
                      child: TextFormField(
                        controller: _organizerContactController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          // Basic phone validation (digits, space, +, -)
                          final phoneRegex = RegExp(r'^[\d\s\+\-]{10,15}$');
                          if (!phoneRegex.hasMatch(value)) return 'Invalid phone number format';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Equipment Required',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableEquipment.map((equipment) {
                        final isSelected = _selectedEquipment.contains(equipment);
                        return FilterChip(
                          label: Text(equipment),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedEquipment.add(equipment);
                              } else {
                                _selectedEquipment.remove(equipment);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    FormFieldWrapper(
                      label: 'Additional Tech Setup Notes',
                      child: TextFormField(
                        controller: _techSetupController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Any specific setup required? (e.g. 2 lapel mics, HDMI input)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Submit Request',
                isLoading: _isSubmitting,
                onPressed: _submitForm,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
