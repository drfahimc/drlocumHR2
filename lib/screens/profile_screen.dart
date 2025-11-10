import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/common/top_nav_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_menu_item.dart';
import 'my_jobs_screen.dart';
import 'summary_screen.dart';
import 'notifications_screen.dart';
import 'reports_analytics_screen.dart';
import 'hospital_info_screen.dart';
import 'my_doctors_screen.dart';
import 'ratings_feedback_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedBottomNavIndex = 3;

  // Sample profile data
  final String _doctorName = 'Dr. Rajesh Kumar';
  final String _doctorRole = AppStrings.doctorRole;
  final int _notificationCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            TopNavBar(
              title: AppStrings.profile,
              notificationCount: _notificationCount,
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Header
                    ProfileHeader(
                      name: _doctorName,
                      role: _doctorRole,
                      onAvatarTap: () {
                        // TODO: Open profile edit or image picker
                      },
                    ),
                    const SizedBox(height: 24),
                    // Menu Items
                    _buildMenuItems(),
                    const SizedBox(height: 16),
                    // Version Info
                    _buildVersionInfo(),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyJobsScreen(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SummaryScreen(),
        ),
      );
    }
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.notifications_outlined,
          title: AppStrings.notifications,
          badgeCount: _notificationCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.analytics_outlined,
          title: AppStrings.reportsAndAnalytics,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportsAnalyticsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.local_hospital_outlined,
          title: AppStrings.hospitalInformation,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HospitalInfoScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.people_outline,
          title: AppStrings.myDoctors,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyDoctorsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.star_outline,
          title: AppStrings.ratingsAndFeedback,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RatingsFeedbackScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: AppStrings.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.description_outlined,
          title: AppStrings.termsAndConditions,
          onTap: () {
            // TODO: Navigate to terms screen
            _showComingSoon(context);
          },
        ),
        const SizedBox(height: 24),
        // Logout Button
        ProfileMenuItem(
          icon: Icons.logout,
          title: AppStrings.logout,
          isDestructive: true,
          onTap: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      AppStrings.appVersion,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout logic
                // This would typically clear user session and navigate to login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

