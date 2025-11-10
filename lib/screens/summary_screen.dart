import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/common/top_nav_bar.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/summary/payment_stat_card.dart';
import '../widgets/summary/date_range_filter.dart';
import '../widgets/summary/shift_status_filter.dart';
import '../services/payments_service.dart';
import '../services/shifts_service.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import 'my_jobs_screen.dart';
import 'profile_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _selectedBottomNavIndex = 2;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _completedShifts = false;
  bool _cancelledShifts = false;
  
  final PaymentsService _paymentsService = PaymentsService();
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
                  title: 'Payments & Shifts',
                  notificationCount: notificationCount,
                );
              },
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Stats Cards
                    _buildPaymentStats(currentUserId),
                    const SizedBox(height: 16),
                    // Filters Section
                    _buildFiltersSection(),
                    const SizedBox(height: 16),
                    // Shifts List
                    _buildShiftsList(currentUserId),
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
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  Widget _buildPaymentStats(String? currentUserId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: currentUserId != null
          ? _paymentsService.getPaymentStats(currentUserId)
          : Future.value({
              'totalEarnings': 0.0,
              'pendingAmount': 0.0,
              'paidAmount': 0.0,
              'totalPayments': 0,
            }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator())),
              SizedBox(width: 16),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading payment stats: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final stats = snapshot.data ?? {
          'totalEarnings': 0.0,
          'pendingAmount': 0.0,
          'paidAmount': 0.0,
          'totalPayments': 0,
        };

        final pendingPayments = (stats['pendingAmount'] as num).toDouble();
        final completedPayments = (stats['paidAmount'] as num).toDouble();
        final totalPayments = stats['totalPayments'] as int;

        return Row(
          children: [
            Expanded(
              child: PaymentStatCard(
                title: 'Pending Payments',
                pending: pendingPayments.toInt(),
                total: totalPayments,
                isCompleted: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PaymentStatCard(
                title: 'Completed Payments',
                pending: completedPayments.toInt(),
                total: totalPayments,
                isCompleted: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      children: [
        DateRangeFilter(
          fromDate: _fromDate,
          toDate: _toDate,
          onFromDateChanged: (date) {
            setState(() {
              _fromDate = date;
            });
          },
          onToDateChanged: (date) {
            setState(() {
              _toDate = date;
            });
          },
        ),
        const SizedBox(height: 16),
        ShiftStatusFilter(
          completedShifts: _completedShifts,
          cancelledShifts: _cancelledShifts,
          onCompletedChanged: (value) {
            setState(() {
              _completedShifts = value;
            });
          },
          onCancelledChanged: (value) {
            setState(() {
              _cancelledShifts = value;
            });
          },
        ),
        const SizedBox(height: 16),
        // Reset and Find Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _findShifts,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Find',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftsList(String? currentUserId) {
    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view shifts',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    String? status;
    if (_completedShifts && !_cancelledShifts) {
      status = 'Completed';
    } else if (_cancelledShifts && !_completedShifts) {
      status = 'Cancelled';
    }

    return StreamBuilder(
      stream: _shiftsService.streamShifts(
        doctorId: currentUserId,
        status: status,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading shifts: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final shifts = snapshot.data ?? [];
        
        // Filter by date range if provided
        final filteredShifts = shifts.where((shift) {
          if (_fromDate != null && shift.date.isBefore(_fromDate!)) {
            return false;
          }
          if (_toDate != null) {
            final toDateEnd = DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59);
            if (shift.date.isAfter(toDateEnd)) {
              return false;
            }
          }
          return true;
        }).toList();

        if (filteredShifts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Text(
                'No shifts found for the selected filters',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shifts (${filteredShifts.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...filteredShifts.map((shift) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shift.formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(shift.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shift.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(shift.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shift.timeRange,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'started':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _completedShifts = false;
      _cancelledShifts = false;
    });
  }

  void _findShifts() {
    // The stream will automatically update with the new filters
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
