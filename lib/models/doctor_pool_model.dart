import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPoolModel {
  final String id;
  final String hrId;
  final String doctorId;
  final String name;
  final String specialty;
  final int yearsOfExperience;
  final String? avatarUrl;
  final double? rating;
  final String? phone;
  final String? email;
  final String addedAt;

  DoctorPoolModel({
    required this.id,
    required this.hrId,
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.yearsOfExperience,
    this.avatarUrl,
    this.rating,
    this.phone,
    this.email,
    required this.addedAt,
  });

  // Factory constructor from Firestore (pool + doctor data)
  factory DoctorPoolModel.fromFirestore(
    Map<String, dynamic> poolData,
    String poolId,
    Map<String, dynamic> doctorData,
  ) {
    return DoctorPoolModel(
      id: poolId,
      hrId: poolData['hrId'] as String? ?? '',
      doctorId: poolData['doctorId'] as String? ?? '',
      name: doctorData['name'] as String? ?? '',
      specialty: doctorData['specialty'] as String? ?? '',
      yearsOfExperience: doctorData['experience'] as int? ?? 0,
      avatarUrl: doctorData['avatar'] as String?,
      rating: (doctorData['rating'] as num?)?.toDouble(),
      phone: doctorData['phone'] as String?,
      email: null, // Email is in users collection, not doctors
      addedAt: poolData['addedAt'] is Timestamp
          ? (poolData['addedAt'] as Timestamp).toDate().toIso8601String()
          : poolData['addedAt'] as String? ?? '',
    );
  }

  // Legacy fromJson for backward compatibility
  factory DoctorPoolModel.fromJson(Map<String, dynamic> json) {
    return DoctorPoolModel(
      id: json['id'] as String,
      hrId: json['hrId'] as String? ?? '',
      doctorId: json['doctorId'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      addedAt: json['addedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hrId': hrId,
      'doctorId': doctorId,
      'name': name,
      'specialty': specialty,
      'yearsOfExperience': yearsOfExperience,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'phone': phone,
      'email': email,
      'addedAt': addedAt,
    };
  }
}
