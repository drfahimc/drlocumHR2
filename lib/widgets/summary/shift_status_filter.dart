import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ShiftStatusFilter extends StatelessWidget {
  final bool completedShifts;
  final bool cancelledShifts;
  final Function(bool) onCompletedChanged;
  final Function(bool) onCancelledChanged;

  const ShiftStatusFilter({
    super.key,
    required this.completedShifts,
    required this.cancelledShifts,
    required this.onCompletedChanged,
    required this.onCancelledChanged,
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
          const Text(
            'Shift Status',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCheckbox(
                  'Completed Shifts',
                  completedShifts,
                  onCompletedChanged,
                ),
              ),
              Expanded(
                child: _buildCheckbox(
                  'Cancelled Shifts',
                  cancelledShifts,
                  onCancelledChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

