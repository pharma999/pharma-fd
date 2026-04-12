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
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      professionalId: json['professional_id'],
      professionalName: json['professional_name'],
      professionalImage: json['professional_image'],
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      status: json['status'] ?? 'PENDING',
      scheduledAt: json['scheduled_at'] ?? '',
      address: json['address'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'],
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isActive =>
      status == 'PENDING' || status == 'ACCEPTED' || status == 'IN_PROGRESS';
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
