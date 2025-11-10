import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/job_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/jobs/job_card.dart';
import '../services/jobs_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import 'job_details_screen.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  final JobsService _jobsService = JobsService();
  final AuthService _authService = AuthService();
  final NotificationsService _notificationsService = NotificationsService();
  String _selectedFilter = 'All'; // All, Open, Approved, etc.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Open', 'Approved', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                return AppBarWithBack(
                  title: AppStrings.browseAvailableJobs,
                  notificationCount: notificationCount,
                );
              },
            ),
            // Search Bar
            _buildSearchBar(),
            // Filter Chips
            _buildFilterChips(),
            // Jobs List
            Expanded(
              child: _buildJobsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search jobs by title, hospital, specialty...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobsList() {
    // Determine status filter
    String? statusFilter;
    if (_selectedFilter != 'All') {
      statusFilter = _selectedFilter;
    }

    return StreamBuilder<List<JobModel>>(
      stream: _jobsService.streamJobs(status: statusFilter),
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

        // Get and filter jobs
        var jobs = snapshot.data ?? [];
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          jobs = jobs.where((job) {
            final query = _searchQuery;
            return job.role.toLowerCase().contains(query) ||
                job.hospitalName.toLowerCase().contains(query) ||
                job.specialty.toLowerCase().contains(query) ||
                job.location.toLowerCase().contains(query);
          }).toList();
        }

        // Empty state
        if (jobs.isEmpty) {
          return EmptyState(
            message: _searchQuery.isNotEmpty
                ? 'No jobs found matching your search'
                : 'No jobs available at the moment',
          );
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}

