import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/auditorium_model.dart';
import '../../providers/auditorium_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/form_field_wrapper.dart';
import '../../widgets/primary_button.dart';
import '../../data/mock_data.dart'; // For allFacilities list

class VenueEditorScreen extends StatefulWidget {
  final AuditoriumModel? venue;

  const VenueEditorScreen({super.key, this.venue});

  @override
  State<VenueEditorScreen> createState() => _VenueEditorScreenState();
}

class _VenueEditorScreenState extends State<VenueEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _blockController;
  late TextEditingController _descController;
  late TextEditingController _capacityController;
  late TextEditingController _inchargeNameController;
  late TextEditingController _inchargeEmailController;
  late TextEditingController _inchargePhoneController;
  late TextEditingController _imageUrlController;
  
  bool _isActive = true;
  List<String> _selectedFacilities = [];
  
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.venue?.venueName ?? '');
    _blockController = TextEditingController(text: widget.venue?.blockName ?? '');
    _descController = TextEditingController(text: widget.venue?.description ?? '');
    _capacityController = TextEditingController(text: widget.venue?.capacity.toString() ?? '');
    _inchargeNameController = TextEditingController(text: widget.venue?.inchargeName ?? '');
    _inchargeEmailController = TextEditingController(text: widget.venue?.inchargeEmail ?? '');
    _inchargePhoneController = TextEditingController(text: widget.venue?.inchargePhone ?? '');
    _imageUrlController = TextEditingController(text: widget.venue?.imageUrl ?? '');
    
    _isActive = widget.venue?.isActive ?? true;
    _selectedFacilities = widget.venue?.facilities.toList() ?? [];
    _existingImageUrl = widget.venue?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _blockController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    _inchargeNameController.dispose();
    _inchargeEmailController.dispose();
    _inchargePhoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveVenue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<AuditoriumProvider>(context, listen: false);
      String imageUrl = _imageUrlController.text.trim();

      if (_selectedImage != null) {
        imageUrl = await provider.uploadVenueImage(_selectedImage!, _nameController.text);
      }

      final audi = AuditoriumModel(
        venueId: widget.venue?.venueId ?? '',
        venueName: _nameController.text.trim(),
        blockName: _blockController.text.trim(),
        description: _descController.text.trim(),
        capacity: int.tryParse(_capacityController.text) ?? 0,
        imageUrl: imageUrl,
        inchargeName: _inchargeNameController.text.trim(),
        inchargeEmail: _inchargeEmailController.text.trim(),
        inchargePhone: _inchargePhoneController.text.trim(),
        facilities: _selectedFacilities,
        isActive: _isActive,
        createdAt: widget.venue?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.venue == null) {
        await provider.createVenue(audi);
      } else {
        await provider.updateVenue(widget.venue!.venueId, audi);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Venue saved successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving venue: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.venue == null ? 'Create Venue' : 'Edit Venue'),
        actions: [
          if (widget.venue != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('General Info', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormFieldWrapper(
                      label: 'Venue Name',
                      isRequired: true,
                      child: TextFormField(
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Block Name',
                      isRequired: true,
                      child: TextFormField(
                        controller: _blockController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Image URL (Optional)',
                      isRequired: false,
                      child: TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          hintText: 'https://...',
                        ),
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Capacity',
                      isRequired: true,
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Description',
                      isRequired: true,
                      child: TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SwitchListTile(
                      title: Text('Is Active', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                      subtitle: Text('Inactive venues cannot be booked.'),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      activeColor: AppTheme.primaryColor(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Incharge Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FormFieldWrapper(
                      label: 'Name',
                      isRequired: true,
                      child: TextFormField(
                        controller: _inchargeNameController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Email',
                      isRequired: true,
                      child: TextFormField(
                        controller: _inchargeEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    FormFieldWrapper(
                      label: 'Phone',
                      isRequired: true,
                      child: TextFormField(
                        controller: _inchargePhoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
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
                    Text('Facilities', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.allFacilities.map((f) {
                        final isSelected = _selectedFacilities.contains(f);
                        return FilterChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) _selectedFacilities.add(f);
                              else _selectedFacilities.remove(f);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Save Venue',
                isLoading: _isSaving,
                onPressed: _saveVenue,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.borderColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor(context), width: 2),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
              )
            : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(_existingImageUrl!, fit: BoxFit.cover, width: double.infinity),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, size: 48, color: AppTheme.secondaryTextColor(context)),
                      const SizedBox(height: 8),
                      Text('Upload Venue Image', style: GoogleFonts.inter(color: AppTheme.secondaryTextColor(context))),
                    ],
                  ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this venue? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<AuditoriumProvider>(context, listen: false).deleteVenue(widget.venue!.venueId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
