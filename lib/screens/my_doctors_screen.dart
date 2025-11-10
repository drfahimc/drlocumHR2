import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/doctor_pool_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/doctors/doctor_pool_card.dart';
import '../widgets/common/empty_state.dart';
import '../services/doctors_service.dart';
import '../services/auth_service.dart';
import 'add_doctor_screen.dart';

class MyDoctorsScreen extends StatefulWidget {
  const MyDoctorsScreen({super.key});

  @override
  State<MyDoctorsScreen> createState() => _MyDoctorsScreenState();
}

class _MyDoctorsScreenState extends State<MyDoctorsScreen> {
  final DoctorsService _doctorsService = DoctorsService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUserId();

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarWithBack(
          title: AppStrings.myDoctors,
        ),
        body: const Center(
          child: Text(
            'Please log in to view doctors',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: AppStrings.myDoctors,
      ),
      body: Column(
        children: [
          // Add Doctor Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDoctorDialog(),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add Doctor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          // Doctors List with real-time updates
          Expanded(
            child: StreamBuilder<List<DoctorPoolModel>>(
              stream: _doctorsService.streamDoctorPool(currentUserId),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading doctors: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Retry
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Empty state
                final doctors = snapshot.data ?? [];
                if (doctors.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    message: 'No doctors in your pool',
                    subtitle: 'Add doctors to build your preferred pool',
                  );
                }

                // Doctors list
                return RefreshIndicator(
                  onRefresh: () async {
                    // Stream will automatically update
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorPoolCard(
                        doctor: doctor,
                        onRemove: () => _showRemoveConfirmation(doctor),
                        onMoreTap: () => _showDoctorOptions(doctor),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDoctorDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDoctorScreen(),
      ),
    );

    if (result == true) {
      // Doctor was added, the stream will automatically update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully')),
        );
      }
    }
  }

  void _showRemoveConfirmation(DoctorPoolModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Doctor'),
        content: Text('Are you sure you want to remove ${doctor.name} from your pool?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _doctorsService.removeDoctorFromPool(doctor.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor removed successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error removing doctor: $e')),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDoctorOptions(DoctorPoolModel doctor) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to doctor profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement contact functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove from Pool', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmation(doctor);
              },
            ),
          ],
        ),
      ),
    );
  }
}
