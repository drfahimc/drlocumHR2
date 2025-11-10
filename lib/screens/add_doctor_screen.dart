import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/doctor_pool_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/forms/custom_text_field.dart';
import '../services/doctors_service.dart';
import '../services/auth_service.dart';

class AddDoctorScreen extends StatefulWidget {
  final DoctorPoolModel? doctor; // For editing existing doctor

  const AddDoctorScreen({
    super.key,
    this.doctor,
  });

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final DoctorsService _doctorsService = DoctorsService();
  final AuthService _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _ratingController = TextEditingController();
  final _specializationController = TextEditingController();
  final _certificationController = TextEditingController();

  List<String> _specializations = [];
  List<String> _certifications = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields
    if (widget.doctor != null) {
      _nameController.text = widget.doctor!.name;
      _specialtyController.text = widget.doctor!.specialty;
      _experienceController.text = widget.doctor!.yearsOfExperience.toString();
      _phoneController.text = widget.doctor!.phone ?? '';
      _emailController.text = widget.doctor!.email ?? '';
      _avatarUrlController.text = widget.doctor!.avatarUrl ?? '';
      _ratingController.text = widget.doctor!.rating?.toStringAsFixed(1) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    _avatarUrlController.dispose();
    _ratingController.dispose();
    _specializationController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: widget.doctor == null ? 'Add Doctor' : 'Edit Doctor',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image
              _buildImageSection(),
              const SizedBox(height: 24),
              // Basic Information
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              // About Section
              _buildAboutSection(),
              const SizedBox(height: 24),
              // Specializations Section
              _buildSpecializationsSection(),
              const SizedBox(height: 24),
              // Certifications Section
              _buildCertificationsSection(),
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: _avatarUrlController.text.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _avatarUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Image URL',
                hintText: 'Enter image URL',
                controller: _avatarUrlController,
                keyboardType: TextInputType.url,
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _handleImageUpload,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 40,
      color: AppColors.primaryDark,
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Doctor Name',
          hintText: 'Enter doctor name',
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter doctor name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Specialty',
          hintText: 'e.g., Emergency Medicine, Pediatrics',
          controller: _specialtyController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter specialty';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Years of Experience',
          hintText: 'Enter years',
          controller: _experienceController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter years of experience';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Phone',
                hintText: '+91 98765 43210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Email',
                hintText: 'doctor@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Rating',
          hintText: '0.0 - 5.0',
          controller: _ratingController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              final rating = double.tryParse(value);
              if (rating == null || rating < 0 || rating > 5) {
                return 'Rating must be between 0 and 5';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'About Doctor',
          hintText: 'Enter doctor bio, qualifications, etc.',
          controller: _aboutController,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSpecializationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medical_services, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Specializations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Add Specialization',
                hintText: 'e.g., Emergency Care',
                controller: _specializationController,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
              onPressed: () {
                final value = _specializationController.text.trim();
                if (value.isNotEmpty && !_specializations.contains(value)) {
                  setState(() {
                    _specializations.add(value);
                    _specializationController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_specializations.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specializations.map((spec) {
              return Chip(
                label: Text(spec),
                onDeleted: () {
                  setState(() {
                    _specializations.remove(spec);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Certifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Add Certification',
                hintText: 'e.g., MBBS, MD',
                controller: _certificationController,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
              onPressed: () {
                if (_certificationController.text.trim().isNotEmpty) {
                  setState(() {
                    _certifications.add(_certificationController.text.trim());
                    _certificationController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _certifications.map((cert) {
              return Chip(
                label: Text(cert),
                onDeleted: () {
                  setState(() {
                    _certifications.remove(cert);
                  });
                },
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
        ],
      ],
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
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Doctor'),
          ),
        ),
      ],
    );
  }

  void _handleImageUpload() {
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
                // TODO: Implement image picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery picker coming soon'),
                  ),
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
                  const SnackBar(
                    content: Text('Camera coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter URL'),
              onTap: () {
                Navigator.pop(context);
                // Focus on image URL field
                FocusScope.of(context).requestFocus(FocusNode()..requestFocus());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
            content: Text('Please log in to add doctors'),
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
      if (widget.doctor == null) {
        // Create new doctor and add to pool
        await _doctorsService.createDoctorAndAddToPool(
          hrId: currentUserId,
          name: _nameController.text.trim(),
          specialty: _specialtyController.text.trim(),
          experience: int.parse(_experienceController.text.trim()),
          avatar: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
          rating: _ratingController.text.trim().isNotEmpty
              ? double.tryParse(_ratingController.text.trim())
              : null,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          about: _aboutController.text.trim().isNotEmpty
              ? _aboutController.text.trim()
              : null,
          specializations: _specializations.isNotEmpty ? _specializations : null,
          certifications: _certifications.isNotEmpty ? _certifications : null,
        );
      } else {
        // For editing, we would need to update the doctor in the doctors collection
        // This is more complex and would require additional service methods
        // For now, we'll just show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Editing doctors is not yet implemented'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor added successfully'),
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
            content: Text('Error adding doctor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
