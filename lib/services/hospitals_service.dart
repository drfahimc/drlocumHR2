import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';
import 'firebase_service.dart';

class HospitalsService extends FirebaseService {
  final String _collection = 'hospitals';

  /// Get all hospitals
  Future<List<HospitalModel>> getHospitals({String? managedBy}) async {
    try {
      Query query = firestore.collection(_collection);

      if (managedBy != null) {
        query = query.where('managedBy', isEqualTo: managedBy);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => HospitalModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching hospitals: $e');
    }
  }

  /// Get hospital by ID
  Future<HospitalModel?> getHospitalById(String hospitalId) async {
    try {
      final doc = await firestore.collection(_collection).doc(hospitalId).get();
      if (!doc.exists) return null;
      return HospitalModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching hospital: $e');
    }
  }

  /// Create a new hospital
  Future<String> createHospital(HospitalModel hospital) async {
    try {
      final docRef = await firestore.collection(_collection).add(hospital.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating hospital: $e');
    }
  }

  /// Update hospital
  Future<void> updateHospital(String hospitalId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection(_collection).doc(hospitalId).update(updates);
    } catch (e) {
      throw Exception('Error updating hospital: $e');
    }
  }

  /// Delete hospital
  Future<void> deleteHospital(String hospitalId) async {
    try {
      await firestore.collection(_collection).doc(hospitalId).delete();
    } catch (e) {
      throw Exception('Error deleting hospital: $e');
    }
  }

  /// Stream hospitals for real-time updates
  Stream<List<HospitalModel>> streamHospitals({String? managedBy}) {
    Query query = firestore.collection(_collection);

    if (managedBy != null) {
      query = query.where('managedBy', isEqualTo: managedBy);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HospitalModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}

