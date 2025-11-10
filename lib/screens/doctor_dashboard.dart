import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/schedule_model.dart';
import '../models/job_model.dart';
import '../widgets/common/top_nav_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/dashboard/stat_card.dart';
import '../widgets/dashboard/schedule_job_card.dart';
import '../services/jobs_service.dart';
import '../services/shifts_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import 'my_jobs_screen.dart';
import 'summary_screen.dart';
import 'profile_screen.dart';
import 'browse_jobs_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  final JobsService _jobsService = JobsService();
  final ShiftsService _shiftsService = ShiftsService();
  final AuthService _authService = AuthService();
  final NotificationsService _notificationsService = NotificationsService();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUserId();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar with real-time notification count
            StreamBuilder<int>(
              stream: currentUserId != null
                  ? _notificationsService.streamNotifications(currentUserId).map((notifications) {
                      return notifications.where((n) => !n.read).length;
                    })
                  : Stream.value(0),
              builder: (context, snapshot) {
                final notificationCount = snapshot.data ?? 0;
                return TopNavBar(
                  title: AppStrings.dashboard,
                  notificationCount: notificationCount,
                );
              },
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    // Stats Cards
                    _buildStatsSection(currentUserId),
                    // Today's Schedule
                    _buildTodaysSchedule(currentUserId),
                    // Tomorrow's Schedule
                    _buildTomorrowsSchedule(currentUserId),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Navigate to My Jobs screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyJobsScreen()),
      );
    } else if (index == 2) {
      // Navigate to Summary screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SummaryScreen()),
      );
    } else if (index == 3) {
      // Navigate to Profile screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.welcomeBack,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.whatsHappeningToday,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String? currentUserId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<JobModel>>(
                  stream: _jobsService.streamJobs(status: 'Open'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return StatCard(
                        icon: Icons.work_outline,
                        title: AppStrings.availableJobs,
                        value: '...',
                        color: AppColors.primary,
                      );
                    }
                    if (snapshot.hasError) {
                      return StatCard(
                        icon: Icons.work_outline,
                        title: AppStrings.availableJobs,
                        value: '0',
                        color: AppColors.primary,
                      );
                    }
                    final count = snapshot.data?.length ?? 0;
                    return StatCard(
                      icon: Icons.work_outline,
                      title: AppStrings.availableJobs,
                      value: count.toString(),
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<List<JobModel>>(
                  stream: currentUserId != null
                      ? _jobsService.streamJobs(status: 'Applied', createdBy: currentUserId)
                      : Stream.value(<JobModel>[]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return StatCard(
                        icon: Icons.pending_actions_outlined,
                        title: AppStrings.myApplications,
                        value: '...',
                        color: AppColors.warning,
                      );
                    }
                    if (snapshot.hasError) {
                      return StatCard(
                        icon: Icons.pending_actions_outlined,
                        title: AppStrings.myApplications,
                        value: '0',
                        color: AppColors.warning,
                      );
                    }
                    final count = snapshot.data?.length ?? 0;
                    return StatCard(
                      icon: Icons.pending_actions_outlined,
                      title: AppStrings.myApplications,
                      value: count.toString(),
                      color: AppColors.warning,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
            SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BrowseJobsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search, size: 20),
              label: const Text(
                AppStrings.browseAvailableJobs,
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSchedule(String? currentUserId) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.todaysSchedule,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ScheduleModel>>(
            stream: currentUserId != null
                ? _shiftsService.streamShifts(doctorId: currentUserId, status: 'Scheduled')
                : Stream.value(<ScheduleModel>[]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Error loading schedule: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              final shifts = snapshot.data ?? [];
              // Filter for today
              final todayShifts = shifts.where((shift) {
                final shiftDate = shift.date;
                return shiftDate.isAfter(todayStart.subtract(const Duration(days: 1))) &&
                       shiftDate.isBefore(todayEnd);
              }).toList();

              if (todayShifts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'No schedules for today',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: todayShifts
                      .map((shift) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ScheduleJobCard(schedule: shift),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowsSchedule(String? currentUserId) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowEnd = tomorrowStart.add(const Duration(days: 1));

    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.tomorrowsSchedule,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ScheduleModel>>(
            stream: currentUserId != null
                ? _shiftsService.streamShifts(doctorId: currentUserId, status: 'Scheduled')
                : Stream.value(<ScheduleModel>[]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Error loading schedule: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              final shifts = snapshot.data ?? [];
              // Filter for tomorrow
              final tomorrowShifts = shifts.where((shift) {
                final shiftDate = shift.date;
                return shiftDate.isAfter(tomorrowStart.subtract(const Duration(days: 1))) &&
                       shiftDate.isBefore(tomorrowEnd);
              }).toList();

              if (tomorrowShifts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'No schedules for tomorrow',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: tomorrowShifts
                      .map((shift) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ScheduleJobCard(schedule: shift),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
