class EmergencyModel {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String status; // TRIGGERED / DISPATCHED / EN_ROUTE / ARRIVED / RESOLVED / CANCELLED
  final String priority; // LOW / MEDIUM / HIGH / CRITICAL
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? ambulanceId;
  final String? hospitalId;
  final String? hospitalName;
  final String? respondedAt;
  final String? resolvedAt;
  final String createdAt;

  EmergencyModel({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.status,
    required this.priority,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.ambulanceId,
    this.hospitalId,
    this.hospitalName,
    this.respondedAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      familyMemberId: json['family_member_id'],
      status: json['status'] ?? 'TRIGGERED',
      priority: json['priority'] ?? 'HIGH',
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      ambulanceId: json['ambulance_id'],
      hospitalId: json['hospital_id'],
      hospitalName: json['hospital_name'],
      respondedAt: json['responded_at'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isActive =>
      status == 'TRIGGERED' ||
      status == 'DISPATCHED' ||
      status == 'EN_ROUTE' ||
      status == 'ARRIVED';
}

class MedicalRecord {
  final String id;
  final String userId;
  final String? familyMemberId;
  final String title;
  final String type; // LAB_REPORT / PRESCRIPTION / SCAN / VACCINATION / OTHER
  final String fileUrl;
  final String? description;
  final String? doctorName;
  final String? hospitalName;
  final String recordDate;
  final String createdAt;

  MedicalRecord({
    required this.id,
    required this.userId,
    this.familyMemberId,
    required this.title,
    required this.type,
    required this.fileUrl,
    this.description,
    this.doctorName,
    this.hospitalName,
    required this.recordDate,
    required this.createdAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      familyMemberId: json['family_member_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'OTHER',
      fileUrl: json['file_url'] ?? '',
      description: json['description'],
      doctorName: json['doctor_name'],
      hospitalName: json['hospital_name'],
      recordDate: json['record_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? referenceId;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'GENERAL',
      isRead: json['is_read'] ?? false,
      referenceId: json['reference_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
