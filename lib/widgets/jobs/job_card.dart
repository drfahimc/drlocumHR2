import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/job_model.dart';
import '../../screens/job_details_screen.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onReviewApplicants;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.onReviewApplicants,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '${job.specialty} – ${job.duration}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Hospital and Ward
          Text(
            '${job.hospital} – ${job.ward}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Date Range
          Text(
            job.dateRange,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Time
          Text(
            job.time,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          const Divider(
            height: 1,
            color: AppColors.divider,
          ),
          const SizedBox(height: 16),
          // Status and Action
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(job.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(job.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (job.applicantsCount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '👥 ${job.applicantsCount} ${job.applicantsCount == 1 ? AppStrings.applicant : AppStrings.applicants} Waiting',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (job.status == AppStrings.pendingApproval &&
                  onReviewApplicants != null)
                GestureDetector(
                  onTap: onReviewApplicants,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.reviewApplicants,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('approved')) {
      return AppColors.badgeApproved;
    } else if (status.toLowerCase().contains('pending')) {
      return AppColors.badgePending;
    } else if (status.toLowerCase().contains('cancelled')) {
      return AppColors.badgeCancelled;
    } else if (status.toLowerCase().contains('completed')) {
      return AppColors.badgeCompleted;
    }
    return AppColors.badgePending;
  }
}

