import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/applicant_model.dart';
import 'firebase_service.dart';

class ApplicationsService extends FirebaseService {
  final String _collection = 'applications';
  final String _doctorsCollection = 'doctors';

  /// Get applications for a job
  Future<List<ApplicantModel>> getJobApplications(String jobId) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('jobId', isEqualTo: jobId)
          .where('status', isEqualTo: 'Pending')
          .get();

      final applications = snapshot.docs;
      final applicants = <ApplicantModel>[];

      for (var appDoc in applications) {
        final appData = appDoc.data();
        final doctorId = appData['doctorId'] as String;

        // Fetch doctor details
        final doctorDoc = await firestore
            .collection(_doctorsCollection)
            .where('id', isEqualTo: doctorId)
            .limit(1)
            .get();

        if (doctorDoc.docs.isNotEmpty) {
          final doctorData = doctorDoc.docs.first.data();
          applicants.add(ApplicantModel.fromFirestore(
            appData,
            appDoc.id,
            doctorData,
          ));
        }
      }

      return applicants;
    } catch (e) {
      throw Exception('Error fetching applications: $e');
    }
  }

  /// Approve application
  Future<void> approveApplication(String applicationId, String jobId) async {
    try {
      final batch = firestore.batch();

      // Update application status
      final appRef = firestore.collection(_collection).doc(applicationId);
      batch.update(appRef, {
        'status': 'Approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update job status and approved doctor
      final appDoc = await appRef.get();
      final doctorId = appDoc.data()?['doctorId'] as String?;

      if (doctorId != null) {
        final jobRef = firestore.collection('jobs').doc(jobId);
        batch.update(jobRef, {
          'status': 'Approved',
          'approvedDoctorId': doctorId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error approving application: $e');
    }
  }

  /// Reject application
  Future<void> rejectApplication(String applicationId) async {
    try {
      await firestore.collection(_collection).doc(applicationId).update({
        'status': 'Rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error rejecting application: $e');
    }
  }
}

