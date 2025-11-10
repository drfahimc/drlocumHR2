import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_pool_model.dart';
import 'firebase_service.dart';

class DoctorsService extends FirebaseService {
  final String _poolCollection = 'hr_doctor_pool';
  final String _doctorsCollection = 'doctors';

  /// Get doctors in HR's pool
  Future<List<DoctorPoolModel>> getDoctorPool(String hrId) async {
    try {
      // Get pool entries for this HR
      final poolSnapshot = await firestore
          .collection(_poolCollection)
          .where('hrId', isEqualTo: hrId)
          .get();

      final doctors = <DoctorPoolModel>[];

      for (var poolDoc in poolSnapshot.docs) {
        final poolData = poolDoc.data();
        final doctorId = poolData['doctorId'] as String;

        // Fetch doctor details
        final doctorDoc = await firestore
            .collection(_doctorsCollection)
            .doc(doctorId)
            .get();

        if (doctorDoc.exists) {
          final doctorData = doctorDoc.data()!;
          doctors.add(DoctorPoolModel.fromFirestore(
            poolData,
            poolDoc.id,
            doctorData,
          ));
        }
      }

      return doctors;
    } catch (e) {
      throw Exception('Error fetching doctor pool: $e');
    }
  }

  /// Search for doctors by name or specialty
  Future<List<Map<String, dynamic>>> searchDoctors({
    String? name,
    String? specialty,
  }) async {
    try {
      Query query = firestore.collection(_doctorsCollection);

      if (name != null && name.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: name)
            .where('name', isLessThanOrEqualTo: '$name\uf8ff');
      }

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }

      final snapshot = await query.limit(20).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Error searching doctors: $e');
    }
  }

  /// Add doctor to pool
  Future<String> addDoctorToPool(String hrId, String doctorId) async {
    try {
      // Check if already in pool
      final existing = await firestore
          .collection(_poolCollection)
          .where('hrId', isEqualTo: hrId)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Doctor is already in your pool');
      }

      final docRef = await firestore.collection(_poolCollection).add({
        'hrId': hrId,
        'doctorId': doctorId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding doctor to pool: $e');
    }
  }

  /// Create a new doctor and add to pool
  Future<String> createDoctorAndAddToPool({
    required String hrId,
    required String name,
    required String specialty,
    required int experience,
    String? avatar,
    double? rating,
    String? phone,
    String? email,
    String? about,
    List<String>? specializations,
    List<String>? certifications,
  }) async {
    try {
      // First create the doctor
      final doctorRef = await firestore.collection(_doctorsCollection).add({
        'name': name,
        'specialty': specialty,
        'experience': experience,
        'avatar': avatar,
        'rating': rating,
        'phone': phone,
        'verified': false,
        'appliedJobs': [],
        'approvedJobs': [],
        'completedShifts': 0,
        'qualifications': certifications ?? [],
        'skills': specializations ?? [],
        'hospitals': [],
      });

      // Then add to pool
      await addDoctorToPool(hrId, doctorRef.id);

      return doctorRef.id;
    } catch (e) {
      throw Exception('Error creating doctor: $e');
    }
  }

  /// Remove doctor from pool
  Future<void> removeDoctorFromPool(String poolId) async {
    try {
      await firestore.collection(_poolCollection).doc(poolId).delete();
    } catch (e) {
      throw Exception('Error removing doctor from pool: $e');
    }
  }

  /// Stream doctor pool for real-time updates
  Stream<List<DoctorPoolModel>> streamDoctorPool(String hrId) {
    return firestore
        .collection(_poolCollection)
        .where('hrId', isEqualTo: hrId)
        .snapshots()
        .asyncMap((poolSnapshot) async {
      final doctors = <DoctorPoolModel>[];

      for (var poolDoc in poolSnapshot.docs) {
        final poolData = poolDoc.data();
        final doctorId = poolData['doctorId'] as String;

        final doctorDoc = await firestore
            .collection(_doctorsCollection)
            .doc(doctorId)
            .get();

        if (doctorDoc.exists) {
          final doctorData = doctorDoc.data()!;
          doctors.add(DoctorPoolModel.fromFirestore(
            poolData,
            poolDoc.id,
            doctorData,
          ));
        }
      }

      return doctors;
    });
  }
}
