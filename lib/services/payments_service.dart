import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class Payment {
  final String id;
  final String shiftId;
  final String jobId;
  final String doctorId;
  final double amount;
  final String status; // Pending, Processing, Paid
  final DateTime dueDate;
  final DateTime? paidDate;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.shiftId,
    required this.jobId,
    required this.doctorId,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromFirestore(Map<String, dynamic> json, String id) {
    DateTime dueDate;
    if (json['dueDate'] is Timestamp) {
      dueDate = (json['dueDate'] as Timestamp).toDate();
    } else if (json['dueDate'] is String) {
      dueDate = DateTime.parse(json['dueDate']);
    } else {
      dueDate = DateTime.now();
    }

    DateTime? paidDate;
    if (json['paidDate'] != null) {
      if (json['paidDate'] is Timestamp) {
        paidDate = (json['paidDate'] as Timestamp).toDate();
      } else if (json['paidDate'] is String) {
        paidDate = DateTime.parse(json['paidDate']);
      }
    }

    return Payment(
      id: id,
      shiftId: json['shiftId'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      dueDate: dueDate,
      paidDate: paidDate,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toIso8601String()
          : json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate().toIso8601String()
          : json['updatedAt'] as String? ?? '',
    );
  }
}

class PaymentsService extends FirebaseService {
  final String _collection = 'payments';

  /// Get payments for a user (HR or Doctor)
  Future<List<Payment>> getPayments({
    String? doctorId,
    String? status,
  }) async {
    try {
      Query query = firestore.collection(_collection);

      if (doctorId != null) {
        query = query.where('doctorId', isEqualTo: doctorId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats(String? doctorId) async {
    try {
      Query query = firestore.collection(_collection);
      if (doctorId != null) {
        query = query.where('doctorId', isEqualTo: doctorId);
      }

      final snapshot = await query.get();
      final payments = snapshot.docs
          .map((doc) => Payment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      double totalEarnings = 0.0;
      double pendingAmount = 0.0;
      double paidAmount = 0.0;

      for (var payment in payments) {
        totalEarnings += payment.amount;
        if (payment.status == 'Paid') {
          paidAmount += payment.amount;
        } else {
          pendingAmount += payment.amount;
        }
      }

      return {
        'totalEarnings': totalEarnings,
        'pendingAmount': pendingAmount,
        'paidAmount': paidAmount,
        'totalPayments': payments.length,
      };
    } catch (e) {
      throw Exception('Error fetching payment stats: $e');
    }
  }
}

