import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleModel {
  final String id;
  final String jobId;
  final String doctorId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final String status; // Scheduled, Started, Exit Pending, Completed
  final DateTime? checkIn;
  final DateTime? checkOut;
  final Map<String, dynamic>? proofOfCompletion;
  final String createdAt;
  final String updatedAt;

  // Computed fields for frontend compatibility
  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
  String get timeRange => '$startTime - $endTime';
  String get hospital => ''; // Would need to join with jobs
  String get specialty => ''; // Would need to join with jobs

  ScheduleModel({
    required this.id,
    required this.jobId,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.proofOfCompletion,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Firestore
  factory ScheduleModel.fromFirestore(Map<String, dynamic> json, String id) {
    DateTime date;
    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      date = DateTime.parse(json['date']);
    } else {
      date = DateTime.now();
    }

    DateTime? actualStartTime;
    if (json['actualStartTime'] != null) {
      if (json['actualStartTime'] is Timestamp) {
        actualStartTime = (json['actualStartTime'] as Timestamp).toDate();
      } else if (json['actualStartTime'] is String) {
        actualStartTime = DateTime.parse(json['actualStartTime']);
      }
    }

    DateTime? actualEndTime;
    if (json['actualEndTime'] != null) {
      if (json['actualEndTime'] is Timestamp) {
        actualEndTime = (json['actualEndTime'] as Timestamp).toDate();
      } else if (json['actualEndTime'] is String) {
        actualEndTime = DateTime.parse(json['actualEndTime']);
      }
    }

    DateTime? checkIn;
    if (json['checkIn'] != null) {
      if (json['checkIn'] is Timestamp) {
        checkIn = (json['checkIn'] as Timestamp).toDate();
      } else if (json['checkIn'] is String) {
        checkIn = DateTime.parse(json['checkIn']);
      }
    }

    DateTime? checkOut;
    if (json['checkOut'] != null) {
      if (json['checkOut'] is Timestamp) {
        checkOut = (json['checkOut'] as Timestamp).toDate();
      } else if (json['checkOut'] is String) {
        checkOut = DateTime.parse(json['checkOut']);
      }
    }

    return ScheduleModel(
      id: id,
      jobId: json['jobId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      date: date,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      actualStartTime: actualStartTime,
      actualEndTime: actualEndTime,
      status: json['status'] as String? ?? 'Scheduled',
      checkIn: checkIn,
      checkOut: checkOut,
      proofOfCompletion: json['proofOfCompletion'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toIso8601String()
          : json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate().toIso8601String()
          : json['updatedAt'] as String? ?? '',
    );
  }

  // Legacy fromJson for backward compatibility
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      actualStartTime: json['actualStartTime'] is String
          ? DateTime.parse(json['actualStartTime'])
          : null,
      actualEndTime: json['actualEndTime'] is String
          ? DateTime.parse(json['actualEndTime'])
          : null,
      status: json['status'] as String? ?? 'Scheduled',
      checkIn: json['checkIn'] is String
          ? DateTime.parse(json['checkIn'])
          : null,
      checkOut: json['checkOut'] is String
          ? DateTime.parse(json['checkOut'])
          : null,
      proofOfCompletion: json['proofOfCompletion'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'status': status,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'proofOfCompletion': proofOfCompletion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
