import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String? hospitalLogo;
  final String? hospitalImage;
  final String role;
  final String specialty;
  final String date;
  final String time;
  final String shift;
  final String duration;
  final double pay;
  final double salary;
  final double? distance;
  final double? rating;
  final String status; // Open, Applied, Approved, Taken, Completed
  final int applicants;
  final int applicantsCount;
  final String location;
  final String description;
  final List<String>? requirements;
  final List<String>? qualifications;
  final String? approvedDoctorId;
  final bool urgent;
  final bool qrRequired;
  final String dutyType; // single, multiple
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final List<String>? selectedDays;
  final double paymentPerHour;
  final double totalHours;
  final double totalPay;
  final String publishTo; // all, pool, specific
  final List<String>? specificDoctors;
  final String createdAt;
  final String updatedAt;
  final String createdBy;

  // Computed fields for frontend compatibility
  String get hospital => hospitalName;
  String get ward => location;
  String get dateRange {
    if (dutyType == 'multiple') {
      final start = DateTime.tryParse(startDate.replaceAll('Z', ''));
      final end = DateTime.tryParse(endDate.replaceAll('Z', ''));
      if (start != null && end != null) {
        final days = end.difference(start).inDays + 1;
        return '$startDate - $endDate ($days days)';
      }
    }
    return startDate;
  }

  JobModel({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    this.hospitalLogo,
    this.hospitalImage,
    required this.role,
    required this.specialty,
    required this.date,
    required this.time,
    required this.shift,
    required this.duration,
    required this.pay,
    required this.salary,
    this.distance,
    this.rating,
    required this.status,
    required this.applicants,
    required this.applicantsCount,
    required this.location,
    required this.description,
    this.requirements,
    this.qualifications,
    this.approvedDoctorId,
    required this.urgent,
    required this.qrRequired,
    required this.dutyType,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    this.selectedDays,
    required this.paymentPerHour,
    required this.totalHours,
    required this.totalPay,
    required this.publishTo,
    this.specificDoctors,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Factory constructor from Firestore
  factory JobModel.fromFirestore(Map<String, dynamic> json, String id) {
    return JobModel(
      id: id,
      hospitalId: json['hospitalId'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      hospitalLogo: json['hospitalLogo'] as String?,
      hospitalImage: json['hospitalImage'] as String?,
      role: json['role'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      shift: json['shift'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      pay: (json['pay'] as num?)?.toDouble() ?? 0.0,
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'Open',
      applicants: json['applicants'] as int? ?? 0,
      applicantsCount: json['applicantsCount'] as int? ?? 0,
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'] as List)
          : null,
      qualifications: json['qualifications'] != null
          ? List<String>.from(json['qualifications'] as List)
          : null,
      approvedDoctorId: json['approvedDoctorId'] as String?,
      urgent: json['urgent'] as bool? ?? false,
      qrRequired: json['qrRequired'] as bool? ?? false,
      dutyType: json['dutyType'] as String? ?? 'single',
      startDate: json['startDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      selectedDays: json['selectedDays'] != null
          ? List<String>.from(json['selectedDays'] as List)
          : null,
      paymentPerHour: (json['paymentPerHour'] as num?)?.toDouble() ?? 0.0,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      totalPay: (json['totalPay'] as num?)?.toDouble() ?? 0.0,
      publishTo: json['publishTo'] as String? ?? 'all',
      specificDoctors: json['specificDoctors'] != null
          ? List<String>.from(json['specificDoctors'] as List)
          : null,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toIso8601String()
          : json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate().toIso8601String()
          : json['updatedAt'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      if (hospitalLogo != null) 'hospitalLogo': hospitalLogo,
      if (hospitalImage != null) 'hospitalImage': hospitalImage,
      'role': role,
      'specialty': specialty,
      'date': date,
      'time': time,
      'shift': shift,
      'duration': duration,
      'pay': pay,
      'salary': salary,
      if (distance != null) 'distance': distance,
      if (rating != null) 'rating': rating,
      'status': status,
      'applicants': applicants,
      'applicantsCount': applicantsCount,
      'location': location,
      'description': description,
      if (requirements != null) 'requirements': requirements,
      if (qualifications != null) 'qualifications': qualifications,
      if (approvedDoctorId != null) 'approvedDoctorId': approvedDoctorId,
      'urgent': urgent,
      'qrRequired': qrRequired,
      'dutyType': dutyType,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      if (selectedDays != null) 'selectedDays': selectedDays,
      'paymentPerHour': paymentPerHour,
      'totalHours': totalHours,
      'totalPay': totalPay,
      'publishTo': publishTo,
      if (specificDoctors != null) 'specificDoctors': specificDoctors,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  // Legacy fromJson for backward compatibility
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      hospitalId: json['hospitalId'] as String? ?? '',
      hospitalName: json['hospital'] as String? ?? json['hospitalName'] as String? ?? '',
      role: json['role'] as String? ?? json['specialty'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      date: json['date'] as String? ?? json['dateRange'] as String? ?? '',
      time: json['time'] as String? ?? '',
      shift: json['shift'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      pay: (json['pay'] as num?)?.toDouble() ?? 0.0,
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Open',
      applicants: json['applicantsCount'] as int? ?? json['applicantCount'] as int? ?? 0,
      applicantsCount: json['applicantsCount'] as int? ?? json['applicantCount'] as int? ?? 0,
      location: json['ward'] as String? ?? json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      urgent: json['urgent'] as bool? ?? false,
      qrRequired: json['qrRequired'] as bool? ?? false,
      dutyType: json['dutyType'] as String? ?? 'single',
      startDate: json['startDate'] is DateTime
          ? (json['startDate'] as DateTime).toIso8601String()
          : json['startDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endDate: json['endDate'] is DateTime
          ? (json['endDate'] as DateTime).toIso8601String()
          : json['endDate'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      paymentPerHour: (json['paymentPerHour'] as num?)?.toDouble() ?? 0.0,
      totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
      totalPay: (json['totalPay'] as num?)?.toDouble() ?? 0.0,
      publishTo: json['publishTo'] as String? ?? 'all',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      createdBy: json['createdBy'] as String? ?? '',
    );
  }

  // Legacy toJson for backward compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'hospital': hospitalName,
      'hospitalName': hospitalName,
      'role': role,
      'specialty': specialty,
      'date': date,
      'dateRange': dateRange,
      'time': time,
      'shift': shift,
      'duration': duration,
      'pay': pay,
      'salary': salary,
      'status': status,
      'applicantCount': applicantsCount,
      'applicantsCount': applicantsCount,
      'ward': location,
      'location': location,
      'description': description,
      'urgent': urgent,
      'qrRequired': qrRequired,
      'dutyType': dutyType,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'paymentPerHour': paymentPerHour,
      'totalHours': totalHours,
      'totalPay': totalPay,
      'publishTo': publishTo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }
}
