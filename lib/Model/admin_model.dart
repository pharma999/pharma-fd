// ── Analytics ─────────────────────────────────────────────────────────────

class AdminAnalytics {
  final int totalUsers;
  final int totalDoctors;
  final int totalNurses;
  final int totalHospitals;
  final int totalBookings;
  final int totalAppointments;
  final int activeEmergencies;
  final double totalRevenue;

  AdminAnalytics({
    required this.totalUsers,
    required this.totalDoctors,
    required this.totalNurses,
    required this.totalHospitals,
    required this.totalBookings,
    required this.totalAppointments,
    required this.activeEmergencies,
    required this.totalRevenue,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    return AdminAnalytics(
      totalUsers: json['total_users'] ?? 0,
      totalDoctors: json['total_doctors'] ?? 0,
      totalNurses: json['total_nurses'] ?? 0,
      totalHospitals: json['total_hospitals'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      activeEmergencies: json['active_emergencies'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

// ── Support Ticket ────────────────────────────────────────────────────────

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String subject;
  final String description;
  final String category;
  final String status; // OPEN / IN_PROGRESS / RESOLVED / CLOSED
  final String priority; // LOW / MEDIUM / HIGH / CRITICAL
  final String? assignedTo;
  final String? resolution;
  final String? referenceId;
  final String? resolvedAt;
  final String createdAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.resolution,
    this.referenceId,
    this.resolvedAt,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'OPEN',
      priority: json['priority'] ?? 'MEDIUM',
      assignedTo: json['assigned_to'],
      resolution: json['resolution'],
      referenceId: json['reference_id'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isOpen => status == 'OPEN' || status == 'IN_PROGRESS';
}

// ── Subscription Plan ─────────────────────────────────────────────────────

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String duration; // MONTHLY / QUARTERLY / YEARLY
  final double price;
  final List<String> features;
  final int maxBookings;
  final int maxFamilyMembers;
  final bool isActive;
  final int displayOrder;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.features,
    required this.maxBookings,
    required this.maxFamilyMembers,
    required this.isActive,
    required this.displayOrder,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 'MONTHLY',
      price: (json['price'] ?? 0).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      maxBookings: json['max_bookings'] ?? 0,
      maxFamilyMembers: json['max_family_members'] ?? 0,
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }
}

// ── Platform Settings ─────────────────────────────────────────────────────

class PlatformSettings {
  final double doctorCommissionPct;
  final double nurseCommissionPct;
  final double bookingCommissionPct;
  final double emergencyBaseFee;
  final String supportEmail;
  final String supportPhone;
  final String appVersion;
  final bool maintenanceMode;

  PlatformSettings({
    required this.doctorCommissionPct,
    required this.nurseCommissionPct,
    required this.bookingCommissionPct,
    required this.emergencyBaseFee,
    required this.supportEmail,
    required this.supportPhone,
    required this.appVersion,
    required this.maintenanceMode,
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> json) {
    return PlatformSettings(
      doctorCommissionPct: (json['doctor_commission_pct'] ?? 15).toDouble(),
      nurseCommissionPct: (json['nurse_commission_pct'] ?? 12).toDouble(),
      bookingCommissionPct: (json['booking_commission_pct'] ?? 10).toDouble(),
      emergencyBaseFee: (json['emergency_base_fee'] ?? 500).toDouble(),
      supportEmail: json['support_email'] ?? '',
      supportPhone: json['support_phone'] ?? '',
      appVersion: json['app_version'] ?? '1.0.0',
      maintenanceMode: json['maintenance_mode'] ?? false,
    );
  }
}

// ── Service Zone ──────────────────────────────────────────────────────────

class ServiceZone {
  final String id;
  final String name;
  final String city;
  final String state;
  final List<String> pinCodes;
  final String status; // ACTIVE / INACTIVE / PLANNED

  ServiceZone({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.pinCodes,
    required this.status,
  });

  factory ServiceZone.fromJson(Map<String, dynamic> json) {
    return ServiceZone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCodes: List<String>.from(json['pin_codes'] ?? []),
      status: json['status'] ?? 'PLANNED',
    );
  }
}

// ── Revenue Report ────────────────────────────────────────────────────────

class RevenueReport {
  final double totalRevenue;
  final int totalTransactions;
  final int totalUsers;
  final int activeSubscriptions;
  final List<MonthlyRevenue> monthlyBreakdown;

  RevenueReport({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.monthlyBreakdown,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    return RevenueReport(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      activeSubscriptions: json['active_subscriptions'] ?? 0,
      monthlyBreakdown: (json['monthly_breakdown'] as List<dynamic>? ?? [])
          .map((e) => MonthlyRevenue.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;
  final int count;

  MonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
    required this.count,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? {};
    return MonthlyRevenue(
      year: id['year'] ?? 0,
      month: id['month'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  String get monthName {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return month > 0 && month <= 12 ? names[month] : '';
  }
}
