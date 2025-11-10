import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/job_model.dart';
import '../widgets/common/top_nav_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/common/tab_bar_widget.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/jobs/job_card.dart';
import '../services/jobs_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import 'summary_screen.dart';
import 'profile_screen.dart';
import 'post_job_screen.dart';
import 'job_details_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  int _selectedTabIndex = 0;
  int _selectedBottomNavIndex = 1;
  final JobsService _jobsService = JobsService();
  final AuthService _authService = AuthService();
  final NotificationsService _notificationsService = NotificationsService();

  final List<String> _tabs = [
    AppStrings.toApprove,
    AppStrings.approved,
    AppStrings.cancelled,
    AppStrings.completed,
  ];

  // Map tab index to job status
  String? _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // To Approve
        return 'Open'; // Jobs that need approval
      case 1: // Approved
        return 'Approved';
      case 2: // Cancelled
        return 'Cancelled';
      case 3: // Completed
        return 'Completed';
      default:
        return null;
    }
  }

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
                  title: AppStrings.myJobs,
                  notificationCount: notificationCount,
                );
              },
            ),
            // Tab Bar
            TabBarWidget(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            // Main Content with real-time updates
            Expanded(
              child: _buildJobList(currentUserId),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreateJob,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomNavIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }

  void _handleCreateJob() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PostJobScreen(),
      ),
    );

    if (result == true) {
      // Job was created, the stream will automatically update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully')),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SummaryScreen(),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  Widget _buildJobList(String? currentUserId) {
    final status = _getStatusForTab(_selectedTabIndex);

    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view jobs',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return StreamBuilder<List<JobModel>>(
      stream: _jobsService.streamJobs(
        status: status,
        createdBy: currentUserId,
      ),
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
                  'Error loading jobs: ${snapshot.error}',
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
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const EmptyState();
        }

        // Jobs list
        return RefreshIndicator(
          onRefresh: () async {
            // Stream will automatically update
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobCard(
                  job: job,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsScreen(jobId: job.id),
                      ),
                    );
                  },
                  onReviewApplicants: job.status == 'Open' && job.applicantsCount > 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(jobId: job.id),
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
