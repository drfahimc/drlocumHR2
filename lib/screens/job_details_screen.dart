import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/job_model.dart';
import '../models/applicant_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../services/jobs_service.dart';
import '../services/applications_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel? job;
  final String? jobId;

  const JobDetailsScreen({
    super.key,
    this.job,
    this.jobId,
  }) : assert(job != null || jobId != null, 'Either job or jobId must be provided');

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isDescriptionExpanded = false;
  final JobsService _jobsService = JobsService();
  final ApplicationsService _applicationsService = ApplicationsService();
  JobModel? _job;
  List<ApplicantModel> _applicants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobData();
  }

  Future<void> _loadJobData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load job if jobId is provided
      if (widget.job != null) {
        _job = widget.job;
      } else if (widget.jobId != null) {
        _job = await _jobsService.getJobById(widget.jobId!);
        if (_job == null) {
          setState(() {
            _error = 'Job not found';
            _isLoading = false;
          });
          return;
        }
      }

      // Load applicants
      if (_job != null) {
        _applicants = await _applicationsService.getJobApplications(_job!.id);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool get _qrAttendanceEnabled => _job?.qrRequired ?? false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarWithBack(
          title: 'Job Details',
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _job == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarWithBack(
          title: 'Job Details',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Job not found',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJobData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: 'Job Details',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            _buildJobHeader(),
            const SizedBox(height: 24),
            // Job Details
            _buildJobDetails(),
            const SizedBox(height: 24),
            // Applicants Section
            _buildApplicantsSection(),
            const SizedBox(height: 24),
            // Job Timeline
            _buildJobTimeline(),
            const SizedBox(height: 24),
            // Job Summary
            _buildJobSummary(),
            const SizedBox(height: 24),
            // Cancel Job Button
            _buildCancelJobButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
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
          // Job Title
          Text(
            _job!.specialty,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Hospital Name
          Text(
            _job!.hospital,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                _job!.ward,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            _job!.description.isNotEmpty
                ? _job!.description
                : 'Join our team at ${_job!.hospital} as a ${_job!.specialty}. We are looking for experienced professionals to provide quality healthcare services.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDescriptionExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isDescriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails() {
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
          _buildDetailRow(Icons.calendar_today, 'Date:', _formatDate()),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.access_time, 'Time:', _job!.time),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.schedule, 'Total Hours:', _job!.duration),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.attach_money, 'Per Hour:', '₹${_job!.paymentPerHour.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.payments, 'Total Pay:', '₹${_job!.totalPay.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'QR Attendance:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _qrAttendanceEnabled
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _qrAttendanceEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 12,
                    color: _qrAttendanceEnabled
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildApplicantsSection() {
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
              const Icon(Icons.people, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Applicants (${_applicants.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _applicants.length,
            itemBuilder: (context, index) {
              final applicant = _applicants[index];
              return _buildApplicantCard(applicant);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(ApplicantModel applicant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: applicant.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      applicant.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: AppColors.primaryDark),
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 16),
          // Name and Qualifications
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${applicant.qualifications} • ${applicant.yearsOfExperience} yrs exp',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _handleApproveApplicant(applicant),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showApplicantOptions(applicant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobTimeline() {
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
              const Icon(Icons.access_time, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Job Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Job Created',
            _job!.createdAt.isNotEmpty
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_job!.createdAt))
                : DateFormat('dd/MM/yyyy').format(DateTime.now()),
            Icons.add_circle_outline,
            true,
          ),
          _buildTimelineItem(
            'Doctor Approved',
            null,
            Icons.check_circle_outline,
            false,
          ),
          _buildTimelineItem(
            'Shift Started',
            null,
            Icons.play_circle_outline,
            false,
          ),
          _buildTimelineItem(
            'Shift Ended',
            null,
            Icons.stop_circle,
            false,
          ),
          _buildTimelineItem(
            'Payment Completed',
            null,
            Icons.payment,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String? date,
    IconData icon,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSummary() {
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
              const Icon(Icons.summarize, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Job Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Job ID:', _job!.id),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Job Created:',
            _job!.createdAt.isNotEmpty
                ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_job!.createdAt))
                : 'Not set',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Shift Start:',
            _job!.startDate.isNotEmpty
                ? DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.parse(_job!.startDate.replaceAll('Z', '')))
                : 'Not set',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Shift End:',
            _job!.endDate.isNotEmpty
                ? DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.parse(_job!.endDate.replaceAll('Z', '')))
                : 'Not set',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Hours:', '${_job!.totalHours.toStringAsFixed(0)}h'),
          const SizedBox(height: 8),
          _buildSummaryRow('Per Hour:', '₹${_job!.paymentPerHour.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Pay:', '₹${_job!.totalPay.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Status:', _job!.status),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelJobButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleCancelJob,
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: const Text('Cancel Job'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    if (_job!.startDate.isNotEmpty) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(_job!.startDate.replaceAll('Z', '')));
      } catch (e) {
        return _job!.dateRange;
      }
    }
    return _job!.dateRange;
  }

  void _handleApproveApplicant(ApplicantModel applicant) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Applicant'),
        content: Text('Are you sure you want to approve ${applicant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _applicationsService.approveApplication(applicant.id, _job!.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${applicant.name} approved successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Reload data
                  _loadJobData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error approving applicant: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showApplicantOptions(ApplicantModel applicant) {
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
              leading: const Icon(Icons.close, color: AppColors.error),
              title: const Text('Reject', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await _applicationsService.rejectApplication(applicant.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${applicant.name} rejected'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    // Reload data
                    _loadJobData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error rejecting applicant: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleCancelJob() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Job'),
        content: const Text('Are you sure you want to cancel this job? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await _jobsService.updateJob(_job!.id, {'status': 'Cancelled'});
                if (mounted) {
                  Navigator.pop(context, true); // Return to previous screen with cancellation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job cancelled successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling job: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

