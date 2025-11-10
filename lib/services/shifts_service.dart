import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'firebase_service.dart';

class ShiftsService extends FirebaseService {
  final String _collection = 'shifts';

  /// Get shifts for a doctor
  Future<List<ScheduleModel>> getShifts({
    String? doctorId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore.collection(_collection);

      if (doctorId != null) {
        query = query.where('doctorId', isEqualTo: doctorId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('date', descending: false);

      final snapshot = await query.get();
      final shifts = snapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filter by date range if provided
      if (startDate != null || endDate != null) {
        shifts.removeWhere((shift) {
          final shiftDate = shift.date;
          if (startDate != null && shiftDate.isBefore(startDate)) return true;
          if (endDate != null && shiftDate.isAfter(endDate)) return true;
          return false;
        });
      }

      return shifts;
    } catch (e) {
      throw Exception('Error fetching shifts: $e');
    }
  }

  /// Stream shifts for real-time updates
  Stream<List<ScheduleModel>> streamShifts({
    String? doctorId,
    String? status,
  }) {
    Query query = firestore.collection(_collection);

    if (doctorId != null) {
      query = query.where('doctorId', isEqualTo: doctorId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('date', descending: false);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ScheduleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}

