import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/schedule_model.dart';

class ScheduleJobCard extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleJobCard({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(schedule.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  schedule.doctorId.isNotEmpty ? 'Doctor Assigned' : 'No Doctor Assigned',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(schedule.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  schedule.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(schedule.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            schedule.hospital.isNotEmpty ? schedule.hospital : 'Hospital',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                schedule.specialty.isNotEmpty ? schedule.specialty : 'Specialty',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                schedule.timeRange,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                schedule.formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('started')) {
      return AppColors.success;
    } else if (status.toLowerCase().contains('applicant')) {
      return AppColors.primary;
    } else {
      return AppColors.warning;
    }
  }
}

