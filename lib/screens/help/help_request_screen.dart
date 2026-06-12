// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/help_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incharge_provider.dart';
import '../../providers/auditorium_provider.dart';
import '../../models/help_request_model.dart';
import '../../models/incharge_model.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';

class HelpRequestScreen extends StatefulWidget {
  const HelpRequestScreen({super.key});

  @override
  State<HelpRequestScreen> createState() => _HelpRequestScreenState();
}

class _HelpRequestScreenState extends State<HelpRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _chairsController = TextEditingController(text: '0');

  String? _selectedBookingId;
  final List<String> _selectedItems = [];

  final List<String> _supportItems = ['Mic', 'Chairs', 'AC Remote', 'Speakers', 'Podium', 'Extension Box'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Rebuild to update FAB visibility when tab changes
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _chairsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final bookingProvider = Provider.of<BookingProvider>(context);
    final helpProvider = Provider.of<HelpProvider>(context);
    final inchargeProvider = Provider.of<InchargeProvider>(context);
    final auditoriumProvider = Provider.of<AuditoriumProvider>(context);

    // Get only approved bookings of this user to request help for
    final userBookings = bookingProvider.bookings.where((b) => b.userId == (user?.id ?? 'u1')).toList();
    final canEdit = authProvider.canEditIncharges;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Support & Help', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryCyan,
          labelColor: AppTheme.primaryCyan,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              icon: Icon(Icons.request_page_rounded),
              text: 'Request Items',
            ),
            Tab(
              icon: Icon(Icons.contact_phone_rounded),
              text: 'Venue In-charges',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Request items
          _buildRequestItemsTab(context, user, userBookings, helpProvider),
          // Tab 2: Incharges contacts
          _buildInchargesTab(context, inchargeProvider, auditoriumProvider, canEdit),
        ],
      ),
      floatingActionButton: _tabController.index == 1 && canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showInchargeForm(context, inchargeProvider, auditoriumProvider),
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: Text('Add In-charge', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: AppTheme.primaryPurple,
            )
          : null,
    );
  }

  Widget _buildRequestItemsTab(
    BuildContext context,
    dynamic user,
    List<dynamic> userBookings,
    HelpProvider helpProvider,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Need items during your event?',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Request mics, chairs, AC remotes, or speakers directly from the venue coordinators.',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedBookingId,
            decoration: const InputDecoration(labelText: 'Select Your Event/Booking'),
            items: userBookings.map((b) => DropdownMenuItem(value: b.id as String, child: Text(b.eventName as String))).toList(),
            validator: (v) => v == null ? 'Please select a booking' : null,
            onChanged: (val) {
              setState(() => _selectedBookingId = val);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Select Items Required',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _supportItems.map((item) {
              final isSelected = _selectedItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedItems.add(item);
                    } else {
                      _selectedItems.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedItems.contains('Chairs')) ...[
            const SizedBox(height: 20),
            TextFormField(
              controller: _chairsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Chairs Required',
                hintText: 'e.g. 50',
              ),
              validator: (v) {
                if (_selectedItems.contains('Chairs')) {
                  if (v == null || v.isEmpty || int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Please enter a valid count';
                  }
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Additional Notes / Instructions',
              hintText: 'Describe where or when you need these items...',
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Submit Support Request',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one item to request.')),
                  );
                  return;
                }

                final selectedBooking = userBookings.firstWhere((b) => b.id == _selectedBookingId);

                final newRequest = HelpRequestModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  bookingId: selectedBooking.id,
                  bookingName: selectedBooking.eventName,
                  requestedBy: user?.name ?? 'User',
                  items: _selectedItems,
                  chairCount: _selectedItems.contains('Chairs') ? (int.tryParse(_chairsController.text) ?? 0) : 0,
                  additionalNotes: _notesController.text,
                  createdAt: DateTime.now(),
                );

                helpProvider.createRequest(newRequest);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Request Sent!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    content: const Text('Venue management coordinators have been notified. We will deliver the requested items shortly.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Pop dialog
                          setState(() {
                            _selectedBookingId = null;
                            _selectedItems.clear();
                            _notesController.clear();
                            _chairsController.text = '0';
                          });
                        },
                        child: const Text('OK'),
                      )
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Requests',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Consumer<HelpProvider>(
            builder: (context, help, _) {
              final myReqs = help.requests;
              if (myReqs.isEmpty) {
                return Text('No recent requests.', style: GoogleFonts.inter(color: AppTheme.textSecondary));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myReqs.length,
                itemBuilder: (context, idx) {
                  final req = myReqs[idx];
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                req.bookingName,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: req.status == 'Resolved' ? AppTheme.success.withOpacity(0.2) : AppTheme.pending.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                req.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: req.status == 'Resolved' ? AppTheme.success : AppTheme.pending,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Requested: ${req.items.join(', ')}', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                        if (req.chairCount > 0)
                          Text('Chairs quantity: ${req.chairCount}', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInchargesTab(
    BuildContext context,
    InchargeProvider inchargeProvider,
    AuditoriumProvider auditoriumProvider,
    bool canEdit,
  ) {
    final list = inchargeProvider.incharges;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_rounded, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text('No in-charges configured yet.', style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final incharge = list[index];
        final nameInitials = incharge.name.isNotEmpty
            ? incharge.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
            : 'IC';

        return GlassCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                child: Text(
                  nameInitials,
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incharge.name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incharge.designation,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.primaryCyan,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          incharge.assignedVenue,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          incharge.phone,
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            incharge.email,
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone_in_talk_rounded, color: AppTheme.success, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Simulating call to ${incharge.name} at ${incharge.phone}...')),
                          );
                        },
                        tooltip: 'Call',
                      ),
                      IconButton(
                        icon: const Icon(Icons.mail_outline_rounded, color: AppTheme.primaryCyan, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Simulating email composition to ${incharge.email}...')),
                          );
                        },
                        tooltip: 'Email',
                      ),
                    ],
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppTheme.accentAmber, size: 20),
                          onPressed: () => _showInchargeForm(context, inchargeProvider, auditoriumProvider, incharge),
                          tooltip: 'Edit Details',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                          onPressed: () => _confirmDelete(context, inchargeProvider, incharge),
                          tooltip: 'Delete Contact',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, InchargeProvider provider, InchargeModel incharge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the contact for ${incharge.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              provider.deleteIncharge(incharge.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${incharge.name} removed from venue in-charges.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInchargeForm(
    BuildContext context,
    InchargeProvider provider,
    AuditoriumProvider auditoriumProvider, [
    InchargeModel? incharge,
  ]) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: incharge?.name ?? '');
    final phoneCtrl = TextEditingController(text: incharge?.phone ?? '');
    final emailCtrl = TextEditingController(text: incharge?.email ?? '');
    final desCtrl = TextEditingController(text: incharge?.designation ?? '');

    // Get all venues and add "All Venues"
    final venues = ['All Venues', ...auditoriumProvider.auditoriums.map((a) => a.name)];
    String selectedVenue = incharge != null && venues.contains(incharge.assignedVenue)
        ? incharge.assignedVenue
        : 'All Venues';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.largeRadius)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        incharge == null ? 'Add Venue In-charge' : 'Edit In-charge Details',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_rounded),
                      hintText: 'e.g. Dr. John Doe',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: desCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Designation',
                      prefixIcon: Icon(Icons.badge_rounded),
                      hintText: 'e.g. Venue Coordinator',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter designation' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_rounded),
                      hintText: 'e.g. +91 98765 43210',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_rounded),
                      hintText: 'e.g. john.doe@christuniversity.in',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter email address';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedVenue,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Venue',
                      prefixIcon: Icon(Icons.meeting_room_rounded),
                    ),
                    dropdownColor: AppTheme.cardBg,
                    items: venues
                        .map((venue) => DropdownMenuItem(
                              value: venue,
                              child: Text(venue),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedVenue = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    text: incharge == null ? 'Add Contact' : 'Save Changes',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final updated = InchargeModel(
                          id: incharge?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          designation: desCtrl.text.trim(),
                          assignedVenue: selectedVenue,
                        );

                        if (incharge == null) {
                          provider.addIncharge(updated);
                        } else {
                          provider.updateIncharge(incharge.id, updated);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              incharge == null
                                  ? 'In-charge contact added successfully.'
                                  : 'In-charge contact updated successfully.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
