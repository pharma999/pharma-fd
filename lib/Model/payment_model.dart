class PaymentModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String? appointmentId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status; // PENDING | COMPLETED | FAILED | REFUNDED
  final String? transactionId;
  final String? paidAt;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    this.bookingId,
    this.appointmentId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      bookingId: json['booking_id'],
      appointmentId: json['appointment_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'PENDING',
      transactionId: json['transaction_id'],
      paidAt: json['paid_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isPaid => status == 'COMPLETED';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
}
