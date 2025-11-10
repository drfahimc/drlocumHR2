import '../models/message_model.dart';
import 'firebase_service.dart';

class MessagesService extends FirebaseService {
  final String _collection = 'admin_messages';

  /// Get messages for a user
  Future<List<MessageModel>> getMessages(String userId) async {
    try {
      final snapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  /// Send a message
  Future<String> sendMessage(MessageModel message) async {
    try {
      final docRef = await firestore.collection(_collection).add(message.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Stream messages for real-time updates
  Stream<List<MessageModel>> streamMessages(String userId) {
    return firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return MessageModel.fromFirestore(data, doc.id);
          })
          .toList();
    });
  }
}

