import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantModel {
  final String id;
  final String jobId;
  final String doctorId;
  final String name;
  final String qualifications;
  final int yearsOfExperience;
  final String? avatarUrl;
  final String? specialty;
  final String appliedAt;
  final String status;
  final String? coverNote;

  ApplicantModel({
    required this.id,
    required this.jobId,
    required this.doctorId,
    required this.name,
    required this.qualifications,
    required this.yearsOfExperience,
    this.avatarUrl,
    this.specialty,
    required this.appliedAt,
    required this.status,
    this.coverNote,
  });

  // Factory constructor from Firestore (application + doctor data)
  factory ApplicantModel.fromFirestore(
    Map<String, dynamic> appData,
    String appId,
    Map<String, dynamic> doctorData,
  ) {
    final qualifications = doctorData['qualifications'] as List<dynamic>? ?? [];
    final qualString = qualifications.isNotEmpty
        ? qualifications.first.toString()
        : 'MBBS';

    return ApplicantModel(
      id: appId,
      jobId: appData['jobId'] as String? ?? '',
      doctorId: appData['doctorId'] as String? ?? '',
      name: doctorData['name'] as String? ?? '',
      qualifications: qualString,
      yearsOfExperience: doctorData['experience'] as int? ?? 0,
      avatarUrl: doctorData['avatar'] as String?,
      specialty: doctorData['specialty'] as String?,
      appliedAt: appData['appliedAt'] is Timestamp
          ? (appData['appliedAt'] as Timestamp).toDate().toIso8601String()
          : appData['appliedAt'] as String? ?? '',
      status: appData['status'] as String? ?? 'Pending',
      coverNote: appData['coverNote'] as String?,
    );
  }

  // Legacy fromJson for backward compatibility
  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      name: json['name'] as String,
      qualifications: json['qualifications'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      specialty: json['specialty'] as String?,
      appliedAt: json['appliedAt'] as String? ?? DateTime.now().toIso8601String(),
      status: json['status'] as String? ?? 'Pending',
      coverNote: json['coverNote'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'doctorId': doctorId,
      'name': name,
      'qualifications': qualifications,
      'yearsOfExperience': yearsOfExperience,
      'avatarUrl': avatarUrl,
      'specialty': specialty,
      'appliedAt': appliedAt,
      'status': status,
      'coverNote': coverNote,
    };
  }
}
