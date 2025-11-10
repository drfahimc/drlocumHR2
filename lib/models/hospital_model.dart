import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String id;
  final String managedBy;
  final String name;
  final String description;
  final String? image;
  final String contactNumber;
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String createdAt;
  final String updatedAt;

  // Computed fields for frontend compatibility
  String get phone => contactNumber;
  String? get imageUrl => image;

  HospitalModel({
    required this.id,
    required this.managedBy,
    required this.name,
    required this.description,
    this.image,
    required this.contactNumber,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Firestore
  factory HospitalModel.fromFirestore(Map<String, dynamic> json, String id) {
    return HospitalModel(
      id: id,
      managedBy: json['managedBy'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      contactNumber: json['contactNumber'] as String? ?? '',
      location: json['location'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toIso8601String()
          : json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate().toIso8601String()
          : json['updatedAt'] as String? ?? '',
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'managedBy': managedBy,
      'name': name,
      'description': description,
      if (image != null) 'image': image,
      'contactNumber': contactNumber,
      'location': location,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Legacy fromJson for backward compatibility
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String,
      managedBy: json['managedBy'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['imageUrl'] as String? ?? json['image'] as String?,
      contactNumber: json['phone'] as String? ?? json['contactNumber'] as String? ?? '',
      location: json['location'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Legacy toJson for backward compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managedBy': managedBy,
      'name': name,
      'description': description,
      'image': image,
      'imageUrl': image,
      'phone': contactNumber,
      'contactNumber': contactNumber,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
