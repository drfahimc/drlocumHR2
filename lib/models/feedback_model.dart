import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedbackModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorAvatar;
  final String? specialty;
  final double rating;
  final String feedbackText;
  final DateTime date;
  final String? jobId;
  final String? jobTitle;
  final String createdBy;
  final String createdAt;

  // Computed fields for frontend compatibility
  String get formattedDate => DateFormat('dd MMM yyyy').format(date);

  FeedbackModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorAvatar,
    this.specialty,
    required this.rating,
    required this.feedbackText,
    required this.date,
    this.jobId,
    this.jobTitle,
    required this.createdBy,
    required this.createdAt,
  });

  // Factory constructor from Firestore
  factory FeedbackModel.fromFirestore(Map<String, dynamic> json, String id) {
    DateTime date;
    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      date = DateTime.parse(json['date']);
    } else {
      date = DateTime.now();
    }

    return FeedbackModel(
      id: id,
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorAvatar: json['doctorAvatar'] as String?,
      specialty: null, // Not in backend, would need to join with doctors
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      feedbackText: json['comment'] as String? ?? '',
      date: date,
      jobId: json['jobId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toIso8601String()
          : json['createdAt'] as String? ?? '',
    );
  }

  // Legacy fromJson for backward compatibility
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String,
      doctorAvatar: json['doctorAvatar'] as String?,
      specialty: json['specialty'] as String?,
      rating: (json['rating'] as num).toDouble(),
      feedbackText: json['feedbackText'] as String? ?? json['comment'] as String? ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      jobId: json['jobId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorAvatar': doctorAvatar,
      'specialty': specialty,
      'rating': rating,
      'feedbackText': feedbackText,
      'comment': feedbackText,
      'date': date.toIso8601String(),
      'jobId': jobId,
      'jobTitle': jobTitle,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
