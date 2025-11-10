import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum NotificationType {
  application,
  approval,
  shift,
  payment,
  message,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String? actionUrl;
  final String? relatedEntityId;
  final String? relatedEntityType;

  // Computed fields for frontend compatibility
  String get description => message;
  bool get isRead => read;
  String get date => DateFormat('dd/MM/yyyy').format(timestamp);

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.read,
    this.actionUrl,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  // Factory constructor from Firestore
  factory NotificationModel.fromFirestore(Map<String, dynamic> json, String id) {
    NotificationType type;
    final typeString = json['type'] as String? ?? '';
    switch (typeString) {
      case 'application':
        type = NotificationType.application;
        break;
      case 'approval':
        type = NotificationType.approval;
        break;
      case 'shift':
        type = NotificationType.shift;
        break;
      case 'payment':
        type = NotificationType.payment;
        break;
      case 'message':
        type = NotificationType.message;
        break;
      default:
        type = NotificationType.message;
    }

    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    return NotificationModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: timestamp,
      read: json['read'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
    );
  }

  // Legacy fromJson for backward compatibility
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    final typeString = json['type'] as String? ?? '';
    switch (typeString) {
      case 'application':
        type = NotificationType.application;
        break;
      case 'approval':
        type = NotificationType.approval;
        break;
      case 'shift':
        type = NotificationType.shift;
        break;
      case 'payment':
        type = NotificationType.payment;
        break;
      case 'message':
        type = NotificationType.message;
        break;
      default:
        type = NotificationType.message;
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      type: type,
      title: json['title'] as String,
      message: json['description'] as String? ?? json['message'] as String? ?? '',
      timestamp: json['date'] is String
          ? DateTime.parse(json['date'])
          : json['timestamp'] is String
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      read: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'description': message,
      'timestamp': timestamp.toIso8601String(),
      'date': date,
      'read': read,
      'isRead': read,
      'actionUrl': actionUrl,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }
}
