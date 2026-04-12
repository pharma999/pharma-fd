class DoctorModel {
  final String id;
  final String userId;
  final String name;
  final String profileImage;
  final String specialty;
  final String qualification;
  final int experience;
  final double rating;
  final int totalReviews;
  final double consultationFee;
  final double homeVisitFee;
  final String consultationType; // ONLINE / HOME_VISIT / BOTH
  final String availability; // ONLINE / OFFLINE / BUSY
  final String? hospitalId;
  final String? hospitalName;
  final List<String> languages;
  final List<String> services;
  final List<DoctorSchedule> schedule;

  DoctorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.specialty,
    required this.qualification,
    required this.experience,
    required this.rating,
    required this.totalReviews,
    required this.consultationFee,
    required this.homeVisitFee,
    required this.consultationType,
    required this.availability,
    this.hospitalId,
    this.hospitalName,
    required this.languages,
    required this.services,
    required this.schedule,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image'] ?? '',
      specialty: json['specialty'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      consultationFee: (json['consultation_fee'] ?? 0).toDouble(),
      homeVisitFee: (json['home_visit_fee'] ?? 0).toDouble(),
      consultationType: json['consultation_type'] ?? 'ONLINE',
      availability: json['availability'] ?? 'OFFLINE',
      hospitalId: json['hospital_id'],
      hospitalName: json['hospital_name'],
      languages: List<String>.from(json['languages'] ?? []),
      services: List<String>.from(json['services'] ?? []),
      schedule: (json['schedule'] as List<dynamic>? ?? [])
          .map((s) => DoctorSchedule.fromJson(s))
          .toList(),
    );
  }
}

class DoctorSchedule {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int maxPatients;

  DoctorSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.maxPatients,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] ?? false,
      maxPatients: json['max_patients'] ?? 10,
    );
  }
}

class NurseModel {
  final String id;
  final String userId;
  final String name;
  final String profileImage;
  final String category;
  final String qualification;
  final int experience;
  final double rating;
  final int totalReviews;
  final double hourlyRate;
  final bool isAvailable;
  final List<String> languages;
  final List<String> skills;

  NurseModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.profileImage,
    required this.category,
    required this.qualification,
    required this.experience,
    required this.rating,
    required this.totalReviews,
    required this.hourlyRate,
    required this.isAvailable,
    required this.languages,
    required this.skills,
  });

  factory NurseModel.fromJson(Map<String, dynamic> json) {
    return NurseModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image'] ?? '',
      category: json['category'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}
