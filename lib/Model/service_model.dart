class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['category_id'] ?? json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class ServiceModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double basePrice;
  final String unit;
  final String imageUrl;
  final bool isActive;
  final double rating;
  final int totalReviews;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.unit,
    required this.imageUrl,
    required this.isActive,
    required this.rating,
    required this.totalReviews,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['service_id'] ?? json['id'] ?? json['_id'] ?? '',
      categoryId: json['category_id'] ?? '',
      name: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['base_price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'per visit',
      imageUrl: json['image_url'] ?? '',
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}

class ProfessionalModel {
  final String id;
  final String userId;
  final String serviceId;
  final String name;
  final String profileImage;
  final double rating;
  final int totalReviews;
  final double price;
  final String experience;
  final List<String> skills;
  final bool isAvailable;
  final bool isAdvertised;
  // Fields from backend professional response
  final String roleName;
  final String serviceNameVal;
  final String zoneId;
  final String zoneName;
  final String bio;
  final String qualification;
  final int yearsExp;
  final int durationMins;
  final double hourlyRate;
  final String timeStart;
  final String timeEnd;

  ProfessionalModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.name,
    required this.profileImage,
    required this.rating,
    required this.totalReviews,
    required this.price,
    required this.experience,
    required this.skills,
    required this.isAvailable,
    this.isAdvertised = false,
    this.roleName = '',
    this.serviceNameVal = '',
    this.zoneId = '',
    this.zoneName = '',
    this.bio = '',
    this.qualification = '',
    this.yearsExp = 0,
    this.durationMins = 30,
    this.hourlyRate = 0,
    this.timeStart = '',
    this.timeEnd = '',
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['professional_id'] ?? json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      profileImage: json['profile_image'] ?? json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      price: (json['price'] ?? json['base_price'] ?? json['hourly_rate'] ?? 0).toDouble(),
      experience: json['experience'] ?? json['specialization'] ?? json['role'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      isAvailable: json['is_available'] ?? json['available'] ?? false,
      isAdvertised: json['is_advertised'] ?? false,
      roleName: json['role'] ?? '',
      serviceNameVal: json['service_name'] ?? '',
      zoneId: json['zone_id'] ?? '',
      zoneName: json['zone_name'] ?? '',
      bio: json['bio'] ?? '',
      qualification: json['qualification'] ?? '',
      yearsExp: json['years_experience'] ?? json['years_of_experience'] ?? 0,
      durationMins: json['estimated_duration'] ?? 30,
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      timeStart: json['available_time_start'] ?? '',
      timeEnd: json['available_time_end'] ?? '',
    );
  }

  // ── Convenience getters for UI compatibility ──────────────────────────────
  String get role => roleName.isNotEmpty ? roleName : experience;
  bool get available => isAvailable;
  String get serviceName => serviceNameVal;
  int get yearsExperience => yearsExp;
  String get distance => zoneName.isNotEmpty ? zoneName : '';
  int get estimatedDuration => durationMins;
  String get availableTimeStart => timeStart;
  String get availableTimeEnd => timeEnd;
}

class CartItem {
  final String id;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final String? professionalId;
  final String? professionalName;
  final String? scheduledAt;

  CartItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.quantity,
    this.professionalId,
    this.professionalName,
    this.scheduledAt,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      professionalId: json['professional_id'],
      professionalName: json['professional_name'],
      scheduledAt: json['scheduled_at'],
    );
  }
}
