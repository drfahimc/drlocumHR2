import 'package:cloud_firestore/cloud_firestore.dart';

/// Base Firebase service with common operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  /// Convert Firestore Timestamp to DateTime
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Convert DateTime to Firestore Timestamp
  Timestamp dateTimeToTimestamp(DateTime? dateTime) {
    if (dateTime == null) {
      return Timestamp.now();
    }
    return Timestamp.fromDate(dateTime);
  }

  /// Convert ISO string to DateTime
  DateTime? isoStringToDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Convert DateTime to ISO string
  String dateTimeToIsoString(DateTime? dateTime) {
    if (dateTime == null) return '';
    return dateTime.toIso8601String();
  }
}

