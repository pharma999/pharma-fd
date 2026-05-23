class MedicalRecord {
  final String recordId;
  final String userId;
  final String recordType; // LAB_REPORT | PRESCRIPTION | XRAY | ECG | OTHER
  final String title;
  final String description;
  final String fileUrl;
  final String recordDate;
  final String doctorName;
  final String hospitalName;
  final bool isShared;

  MedicalRecord({
    required this.recordId,
    required this.userId,
    required this.recordType,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.recordDate,
    required this.doctorName,
    required this.hospitalName,
    required this.isShared,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['record_id'] ?? '',
      userId: json['user_id'] ?? '',
      recordType: json['record_type'] ?? 'OTHER',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrl: json['file_url'] ?? '',
      recordDate: (json['record_date'] ?? '').toString().split('T').first,
      doctorName: json['doctor_name'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      isShared: json['is_shared'] ?? false,
    );
  }
}
