import '../models/feedback_model.dart';
import 'firebase_service.dart';

class FeedbackService extends FirebaseService {
  final String _collection = 'feedback';

  /// Get all feedback
  Future<List<FeedbackModel>> getFeedback() async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching feedback: $e');
    }
  }

  /// Stream feedback for real-time updates
  Stream<List<FeedbackModel>> streamFeedback() {
    return firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return FeedbackModel.fromFirestore(data, doc.id);
          })
          .toList();
    });
  }
}

