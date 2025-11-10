import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender {
  hr,
  admin,
}

class MessageModel {
  final String id;
  final MessageSender from;
  final String? userId;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String? issueType;

  // Computed fields for frontend compatibility
  String get sender => from == MessageSender.admin ? 'Admin' : 'You';

  MessageModel({
    required this.id,
    required this.from,
    this.userId,
    required this.message,
    required this.timestamp,
    required this.read,
    this.issueType,
  });

  // Factory constructor from Firestore
  factory MessageModel.fromFirestore(Map<String, dynamic> json, String id) {
    MessageSender from;
    final fromString = json['from'] as String? ?? '';
    if (fromString == 'admin') {
      from = MessageSender.admin;
    } else {
      from = MessageSender.hr;
    }

    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    return MessageModel(
      id: id,
      from: from,
      userId: json['userId'] as String?,
      message: json['message'] as String? ?? '',
      timestamp: timestamp,
      read: json['read'] as bool? ?? false,
      issueType: json['issueType'] as String?,
    );
  }

  // Legacy fromJson for backward compatibility
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    MessageSender from;
    final fromString = json['sender'] as String? ?? json['from'] as String? ?? '';
    if (fromString.toLowerCase() == 'admin') {
      from = MessageSender.admin;
    } else {
      from = MessageSender.hr;
    }

    return MessageModel(
      id: json['id'] as String,
      from: from,
      userId: json['userId'] as String?,
      message: json['message'] as String,
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      read: json['read'] as bool? ?? false,
      issueType: json['issueType'] as String?,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'from': from == MessageSender.admin ? 'admin' : 'hr',
      if (userId != null) 'userId': userId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      if (issueType != null) 'issueType': issueType,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from == MessageSender.admin ? 'admin' : 'hr',
      'sender': sender,
      'userId': userId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'issueType': issueType,
    };
  }
}
