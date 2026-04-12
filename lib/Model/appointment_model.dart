class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String? doctorName;
  final String? doctorImage;
  final String? doctorSpecialty;
  final String? familyMemberId;
  final String type; // HOME_VISIT / ONLINE / QUICK / SCHEDULED / EMERGENCY
  final String status; // PENDING / CONFIRMED / IN_PROGRESS / COMPLETED / CANCELLED / NO_SHOW
  final String scheduledAt;
  final String? address;
  final String? notes;
  final double fee;
  final String? meetingLink;
  final String? createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.doctorName,
    this.doctorImage,
    this.doctorSpecialty,
    this.familyMemberId,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.address,
    this.notes,
    required this.fee,
    this.meetingLink,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'],
      doctorImage: json['doctor_image'],
      doctorSpecialty: json['doctor_specialty'],
      familyMemberId: json['family_member_id'],
      type: json['type'] ?? 'SCHEDULED',
      status: json['status'] ?? 'PENDING',
      scheduledAt: json['scheduled_at'] ?? '',
      address: json['address'],
      notes: json['notes'],
      fee: (json['fee'] ?? 0).toDouble(),
      meetingLink: json['meeting_link'],
      createdAt: json['created_at'],
    );
  }

  bool get isUpcoming =>
      status == 'PENDING' || status == 'CONFIRMED' || status == 'IN_PROGRESS';

  bool get isCompleted => status == 'COMPLETED';

  bool get isCancelled => status == 'CANCELLED' || status == 'NO_SHOW';
}

class PrescriptionModel {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String? doctorName;
  final String patientId;
  final List<PrescriptionItem> medicines;
  final String? notes;
  final String? diagnosis;
  final String? followUpDate;
  final String createdAt;

  PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    this.doctorName,
    required this.patientId,
    required this.medicines,
    this.notes,
    this.diagnosis,
    this.followUpDate,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      appointmentId: json['appointment_id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'],
      patientId: json['patient_id'] ?? '',
      medicines: (json['medicines'] as List<dynamic>? ?? [])
          .map((m) => PrescriptionItem.fromJson(m))
          .toList(),
      notes: json['notes'],
      diagnosis: json['diagnosis'],
      followUpDate: json['follow_up_date'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class PrescriptionItem {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  PrescriptionItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }
}
