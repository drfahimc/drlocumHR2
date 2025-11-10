import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import 'firebase_service.dart';

class JobsService extends FirebaseService {
  final String _collection = 'jobs';

  /// Get all jobs
  Future<List<JobModel>> getJobs({
    String? status,
    String? createdBy,
  }) async {
    try {
      Query query = firestore.collection(_collection);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (createdBy != null) {
        query = query.where('createdBy', isEqualTo: createdBy);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => JobModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  /// Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await firestore.collection(_collection).doc(jobId).get();
      if (!doc.exists) return null;
      return JobModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching job: $e');
    }
  }

  /// Create a new job
  Future<String> createJob(JobModel job) async {
    try {
      final docRef = await firestore.collection(_collection).add(job.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  /// Update job
  Future<void> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection(_collection).doc(jobId).update(updates);
    } catch (e) {
      throw Exception('Error updating job: $e');
    }
  }

  /// Delete job
  Future<void> deleteJob(String jobId) async {
    try {
      await firestore.collection(_collection).doc(jobId).delete();
    } catch (e) {
      throw Exception('Error deleting job: $e');
    }
  }

  /// Stream jobs for real-time updates
  Stream<List<JobModel>> streamJobs({
    String? status,
    String? createdBy,
  }) {
    try {
      Query query = firestore.collection(_collection);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (createdBy != null && createdBy.isNotEmpty) {
        query = query.where('createdBy', isEqualTo: createdBy);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        debugPrint('📊 JobsService: Received ${snapshot.docs.length} jobs from Firestore');
        try {
          final jobs = snapshot.docs
              .map((doc) {
                try {
                  return JobModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                } catch (e) {
                  debugPrint('❌ Error parsing job ${doc.id}: $e');
                  debugPrint('   Data: ${doc.data()}');
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
          debugPrint('✅ JobsService: Successfully parsed ${jobs.length} jobs');
          return jobs;
        } catch (e) {
          debugPrint('❌ JobsService: Error processing jobs: $e');
          return <JobModel>[];
        }
      }).handleError((error) {
        debugPrint('❌ JobsService stream error: $error');
        return <JobModel>[];
      });
    } catch (e) {
      debugPrint('❌ JobsService: Error creating stream: $e');
      return Stream.value(<JobModel>[]);
    }
  }
}

