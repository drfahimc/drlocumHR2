import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/hospital_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/hospital/hospital_card.dart';
import '../widgets/common/empty_state.dart';
import '../services/hospitals_service.dart';
import '../services/auth_service.dart';
import 'add_hospital_screen.dart';
import 'hospital_details_screen.dart';

class HospitalInfoScreen extends StatefulWidget {
  const HospitalInfoScreen({super.key});

  @override
  State<HospitalInfoScreen> createState() => _HospitalInfoScreenState();
}

class _HospitalInfoScreenState extends State<HospitalInfoScreen> {
  final HospitalsService _hospitalsService = HospitalsService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUserId();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: AppStrings.hospitalInformation,
      ),
      body: Column(
        children: [
          // Add Hospital Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddHospitalDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Hospital'),
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
          // Hospitals List with real-time updates
          Expanded(
            child: StreamBuilder<List<HospitalModel>>(
              stream: currentUserId != null
                  ? _hospitalsService.streamHospitals(managedBy: currentUserId)
                  : Stream.value(<HospitalModel>[]),
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
                          'Error loading hospitals: ${snapshot.error}',
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
                final hospitals = snapshot.data ?? [];
                if (hospitals.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_hospital_outlined,
                    message: 'No hospitals found',
                    subtitle: 'Add a hospital to get started',
                  );
                }

                // Hospitals list
                return RefreshIndicator(
                  onRefresh: () async {
                    // Stream will automatically update
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      return HospitalCard(
                        hospital: hospital,
                        onTap: () => _navigateToHospitalDetails(hospital),
                        onMoreTap: () => _showHospitalOptions(hospital),
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

  void _showAddHospitalDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHospitalScreen(),
      ),
    );

    if (result == true) {
      // Hospital was added/updated, the stream will automatically update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital saved successfully')),
        );
      }
    }
  }

  void _navigateToHospitalDetails(HospitalModel hospital) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalDetailsScreen(hospital: hospital),
      ),
    );

    if (result == true) {
      // Hospital was updated/deleted, the stream will automatically update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital updated')),
        );
      }
    }
  }

  void _showHospitalOptions(HospitalModel hospital) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Hospital'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddHospitalScreen(hospital: hospital),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Hospital', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteHospital(hospital);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHospital(HospitalModel hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hospital'),
        content: Text('Are you sure you want to delete ${hospital.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _hospitalsService.deleteHospital(hospital.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hospital deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting hospital: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
