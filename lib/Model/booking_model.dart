class BookingModel {
  final String id;
  final String userId;
  final String? professionalId;
  final String? professionalName;
  final String? professionalImage;
  final String serviceId;
  final String serviceName;
  final String status; // PENDING / ACCEPTED / REJECTED / IN_PROGRESS / COMPLETED / CANCELLED
  final String scheduledAt;
  final String? address;
  final double totalAmount;
  final String? notes;
  final String? cancellationReason;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    this.professionalId,
    this.professionalName,
    this.professionalImage,
    required this.serviceId,
    required this.serviceName,
    required this.status,
    required this.scheduledAt,
    this.address,
    required this.totalAmount,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['booking_id'] ?? json['id'] ?? json['_id'] ?? '',
      userId: json['patient_user_id'] ?? json['user_id'] ?? '',
      professionalId: json['professional_id'],
      professionalName: json['professional_name'],
      professionalImage: json['professional_image'],
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      scheduledAt: json['scheduled_at'] ?? '',
      address: json['patient_address'] ?? json['address'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'],
      cancellationReason: json['cancelled_reason'] ?? json['cancellation_reason'],
      createdAt: json['created_at'] ?? '',
    );
  }

  // ── Status helpers ──────────────────────────────────────────────────────────
  bool get isActive =>
      status == 'PENDING'    ||
      status == 'ASSIGNED'   ||
      status == 'ACCEPTED'   ||
      status == 'IN_PROGRESS';

  /// True when the booking is live (provider is en route or serving).
  bool get isInProgress => status == 'IN_PROGRESS';

  /// Booking is waiting for assignment or acceptance.
  bool get isPending =>
      status == 'PENDING' || status == 'ASSIGNED';

  /// Provider has accepted — heading to patient.
  bool get isAccepted => status == 'ACCEPTED';

  bool get isCompleted => status == 'COMPLETED';

  bool get isCancelled =>
      status == 'CANCELLED' || status == 'EXPIRED' || status == 'REJECTED';

  /// Human-readable label shown on cards.
  String get statusLabel {
    switch (status) {
      case 'PENDING':     return 'Pending';
      case 'ASSIGNED':    return 'Finding Provider';
      case 'ACCEPTED':    return 'Provider En Route';
      case 'IN_PROGRESS': return 'In Progress';
      case 'COMPLETED':   return 'Completed';
      case 'CANCELLED':   return 'Cancelled';
      case 'EXPIRED':     return 'Expired';
      case 'REJECTED':    return 'Rejected';
      default:            return status.replaceAll('_', ' ');
    }
  }
}

class PaymentModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String? appointmentId;
  final String type; // BOOKING / APPOINTMENT
  final double amount;
  final String status; // PENDING / COMPLETED / FAILED / REFUNDED
  final String? paymentMethod;
  final String? transactionId;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.bookingId,
    this.appointmentId,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bookingId: json['booking_id'],
      appointmentId: json['appointment_id'],
      type: json['type'] ?? 'BOOKING',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
