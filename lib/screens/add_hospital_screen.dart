import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/hospital_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/forms/custom_text_field.dart';
import '../services/hospitals_service.dart';
import '../services/auth_service.dart';

class AddHospitalScreen extends StatefulWidget {
  final HospitalModel? hospital; // For editing existing hospital

  const AddHospitalScreen({
    super.key,
    this.hospital,
  });

  @override
  State<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends State<AddHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final HospitalsService _hospitalsService = HospitalsService();
  final AuthService _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields
    if (widget.hospital != null) {
      _nameController.text = widget.hospital!.name;
      _imageUrlController.text = widget.hospital!.imageUrl ?? '';
      _descriptionController.text = widget.hospital!.description;
      _contactController.text = widget.hospital!.phone;
      _locationController.text = widget.hospital!.location;
      _addressController.text = widget.hospital!.address ?? '';
    }

    // Listen to location changes to update map preview
    _locationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: widget.hospital == null ? 'Add Hospital' : 'Edit Hospital',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital Name
              CustomTextField(
                label: 'Hospital Name',
                hintText: 'Enter hospital name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter hospital name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Hospital Image
              CustomTextField(
                label: 'Hospital Image',
                hintText: 'Image URL or upload',
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _handleImageUpload,
                ),
              ),
              const SizedBox(height: 24),
              // Description
              CustomTextField(
                label: 'Description',
                hintText: 'Enter hospital description',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Contact Number
              CustomTextField(
                label: 'Contact Number',
                hintText: '+91 98765 43210',
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Location
              CustomTextField(
                label: 'Location',
                hintText: 'City, Area',
                controller: _locationController,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: _handleLocationSelection,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Full Address
              CustomTextField(
                label: 'Full Address',
                hintText: 'Complete address with pincode',
                controller: _addressController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Map Preview (if location is set)
              if (_locationController.text.isNotEmpty) _buildMapPreview(),
              const SizedBox(height: 32),
              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    final hasLocation = _locationController.text.trim().isNotEmpty;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              hasLocation ? _locationController.text : 'Location not set',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Hospital',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  void _handleImageUpload() {
    // TODO: Implement image picker
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter URL'),
              onTap: () {
                Navigator.pop(context);
                // Focus on image URL field
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleLocationSelection() {
    // TODO: Implement location picker or map selection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Location'),
          content: const Text(
            'Location picker will be implemented here. You can select from map or enter manually.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement location selection
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location picker coming soon')),
                );
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUserId = _authService.getCurrentUserId();
    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to save hospitals'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.hospital == null) {
        // Create new hospital
        final hospital = HospitalModel(
          id: '', // Will be set by service
          managedBy: currentUserId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          image: _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          contactNumber: _contactController.text.trim(),
          location: _locationController.text.trim(),
          address: _addressController.text.trim(),
          latitude: null,
          longitude: null,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        await _hospitalsService.createHospital(hospital);
      } else {
        // Update existing hospital
        await _hospitalsService.updateHospital(
          widget.hospital!.id,
          {
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'image': _imageUrlController.text.trim().isEmpty
                ? null
                : _imageUrlController.text.trim(),
            'contactNumber': _contactController.text.trim(),
            'location': _locationController.text.trim(),
            'address': _addressController.text.trim(),
          },
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.hospital == null
                  ? 'Hospital added successfully'
                  : 'Hospital updated successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving hospital: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
