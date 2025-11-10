import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/job_model.dart';
import '../models/hospital_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/forms/custom_text_field.dart';
import '../services/jobs_service.dart';
import '../services/hospitals_service.dart';
import '../services/auth_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final JobsService _jobsService = JobsService();
  final HospitalsService _hospitalsService = HospitalsService();
  final AuthService _authService = AuthService();
  
  // Controllers
  final _paymentPerHourController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  // State variables
  HospitalModel? _selectedHospital;
  bool _isMultipleDayDuty = false;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String? _selectedRole;
  String _publishTo = 'all';
  bool _qrAttendanceEnabled = true;
  double _paymentPerHour = 0.0;
  bool _isLoading = false;
  List<HospitalModel> _hospitals = [];
  bool _loadingHospitals = true;

  // Sample roles
  final List<String> _roles = [
    'Pediatrician',
    'General Physician',
    'Emergency Physician',
    'Cardiologist',
    'Neurologist',
    'Orthopedic Surgeon',
    'Duty Doctor',
    'RMO',
    'JR',
    'SR',
    'Emergency Medicine Doctor',
    'ICU Doctor',
  ];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      final currentUserId = _authService.getCurrentUserId();
      if (currentUserId != null) {
        final hospitals = await _hospitalsService.getHospitals(managedBy: currentUserId);
        setState(() {
          _hospitals = hospitals;
          _loadingHospitals = false;
        });
      } else {
        setState(() {
          _loadingHospitals = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingHospitals = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hospitals: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _paymentPerHourController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: 'Post New Job',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Hospital
              _buildHospitalSelection(),
              const SizedBox(height: 24),
              // Duty Type / Schedule
              _buildDutyTypeSection(),
              const SizedBox(height: 24),
              // Payment Details
              _buildPaymentSection(),
              const SizedBox(height: 24),
              // QR Attendance
              _buildQRAttendanceSection(),
              const SizedBox(height: 24),
              // Role Selection
              _buildRoleSelection(),
              const SizedBox(height: 24),
              // Publish To
              _buildPublishToSection(),
              const SizedBox(height: 24),
              // Additional Info
              _buildAdditionalInfoSection(),
              const SizedBox(height: 24),
              // Summary Preview
              _buildSummaryPreview(),
              const SizedBox(height: 24),
              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_hospital, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Select Hospital',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () {
                // Show hospital info
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadingHospitals)
          const Center(child: CircularProgressIndicator())
        else if (_hospitals.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No hospitals found. Please add a hospital first.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          GestureDetector(
            onTap: _showHospitalPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedHospital?.name ?? 'Select hospital',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedHospital != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDutyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Duty Type / Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Duty Type Toggle
        Row(
          children: [
            Expanded(
              child: _buildDutyTypeButton(
                'Single Day Duty',
                !_isMultipleDayDuty,
                () => setState(() => _isMultipleDayDuty = false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDutyTypeButton(
                'Multiple Day Duty',
                _isMultipleDayDuty,
                () => setState(() => _isMultipleDayDuty = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Date and Time Inputs
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Start Date',
                _startDate,
                () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeField(
                'Start Time',
                _startTime,
                () => _selectTime(context, true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'End Date',
                _endDate,
                () => _selectDate(context, false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeField(
                'End Time',
                _endTime,
                () => _selectTime(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDutyTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay? time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    time != null
                        ? time.format(context)
                        : 'Select time',
                    style: TextStyle(
                      fontSize: 14,
                      color: time != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payments, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Payment Details',
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
          label: 'Payment Per Hour (₹)',
          hintText: 'Enter amount',
          controller: _paymentPerHourController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _paymentPerHour = double.tryParse(value) ?? 0.0;
            });
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter payment per hour';
            }
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    final totalHours = _calculateTotalHours();
    final totalPay = _paymentPerHour * totalHours;
    final duration = _isMultipleDayDuty
        ? '${_startDate != null && _endDate != null ? _endDate!.difference(_startDate!).inDays + 1 : 0} days'
        : '${totalHours.toStringAsFixed(1)}h';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Hours:', duration),
          const SizedBox(height: 8),
          _buildSummaryRow('Per Hour:', '₹${_paymentPerHour.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Total Pay:', '₹${totalPay.toStringAsFixed(0)}'),
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

  Widget _buildQRAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.qr_code_scanner, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'QR Attendance',
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enable QR Code Attendance',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Switch(
              value: _qrAttendanceEnabled,
              onChanged: (value) {
                setState(() {
                  _qrAttendanceEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.work_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Role Selection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showRolePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedRole ?? 'Select role',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedRole != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.public, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Publish To',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showPublishToPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _publishTo == 'all' ? 'All Doctors' : _publishTo == 'pool' ? 'My Pool' : 'Specific Doctors',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Additional Information',
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
          label: 'Description / Requirements',
          hintText: 'Enter job description, requirements, etc.',
          controller: _additionalInfoController,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSummaryPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Hospital:', _selectedHospital?.name ?? 'Not selected'),
          const SizedBox(height: 8),
          _buildSummaryRow('Role:', _selectedRole ?? 'Not selected'),
          const SizedBox(height: 8),
          _buildSummaryRow('Duty Type:', _isMultipleDayDuty ? 'Multiple Days' : 'Single Day'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Date:',
            _startDate != null && _endDate != null
                ? '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                : 'Not set',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Time:',
            _startTime != null && _endTime != null
                ? '${_startTime!.format(context)} - ${_endTime!.format(context)}'
                : 'Not set',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Payment:', '₹${(_paymentPerHour * _calculateTotalHours()).toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('QR Attendance:', _qrAttendanceEnabled ? 'Enabled' : 'Disabled'),
        ],
      ),
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
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handlePostJob,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: const Text('Post Job'),
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
      ],
    );
  }

  // Helper Methods
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _showHospitalPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Hospital',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final hospital = _hospitals[index];
                return ListTile(
                  title: Text(hospital.name),
                  subtitle: Text(hospital.location),
                  onTap: () {
                    setState(() {
                      _selectedHospital = hospital;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRolePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return ListTile(
                  title: Text(role),
                  onTap: () {
                    setState(() {
                      _selectedRole = role;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPublishToPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Publish To',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('All Doctors'),
              onTap: () {
                setState(() {
                  _publishTo = 'all';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('My Pool'),
              onTap: () {
                setState(() {
                  _publishTo = 'pool';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Specific Doctors'),
              onTap: () {
                setState(() {
                  _publishTo = 'specific';
                });
                Navigator.pop(context);
                // TODO: Show doctor selection
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  double _calculateTotalHours() {
    if (_startDate == null || _endDate == null || _startTime == null || _endTime == null) {
      return 0.0;
    }

    final daysDifference = _endDate!.difference(_startDate!).inDays;
    
    if (_isMultipleDayDuty && daysDifference > 0) {
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
      final totalDuration = endDateTime.difference(startDateTime);
      return totalDuration.inHours + (totalDuration.inMinutes % 60) / 60;
    } else {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      final diffMinutes = endMinutes > startMinutes
          ? endMinutes - startMinutes
          : (24 * 60) - startMinutes + endMinutes;
      return diffMinutes / 60;
    }
  }

  void _handlePostJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHospital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hospital'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUserId = _authService.getCurrentUserId();
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to post jobs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate values
      final totalHours = _calculateTotalHours();
      final totalPay = _paymentPerHour * totalHours;
      
      // Format dates and times
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final startDateStr = startDateTime.toIso8601String() + 'Z';
      final endDateStr = endDateTime.toIso8601String() + 'Z';
      final startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

      // Determine specialty from role
      final specialty = _selectedRole!;

      // Create job model
      final job = JobModel(
        id: '', // Will be set by service
        hospitalId: _selectedHospital!.id,
        hospitalName: _selectedHospital!.name,
        hospitalLogo: _selectedHospital!.imageUrl,
        hospitalImage: _selectedHospital!.imageUrl,
        role: _selectedRole!,
        specialty: specialty,
        date: startDateStr,
        time: '$startTimeStr to $endTimeStr',
        shift: _startTime!.hour < 12 ? 'Morning' : _startTime!.hour < 18 ? 'Evening' : 'Night',
        duration: '${totalHours.toStringAsFixed(0)}h',
        pay: _paymentPerHour,
        salary: totalPay,
        distance: null,
        rating: null,
        status: 'Open',
        applicants: 0,
        applicantsCount: 0,
        location: _selectedHospital!.location,
        description: _additionalInfoController.text.trim().isNotEmpty
            ? _additionalInfoController.text.trim()
            : 'Looking for ${_selectedRole} for ${_selectedHospital!.name}.',
        requirements: null,
        qualifications: null,
        approvedDoctorId: null,
        urgent: false,
        qrRequired: _qrAttendanceEnabled,
        dutyType: _isMultipleDayDuty ? 'multiple' : 'single',
        startDate: startDateStr,
        startTime: startTimeStr,
        endDate: endDateStr,
        endTime: endTimeStr,
        selectedDays: null,
        paymentPerHour: _paymentPerHour,
        totalHours: totalHours,
        totalPay: totalPay,
        publishTo: _publishTo,
        specificDoctors: _publishTo == 'specific' ? [] : null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        createdBy: currentUserId,
      );

      // Save to Firebase
      await _jobsService.createJob(job);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully'),
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
            content: Text('Error posting job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
