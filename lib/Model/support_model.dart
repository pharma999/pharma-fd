class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final String category;
  final String status;   // OPEN | IN_REVIEW | RESOLVED | CLOSED
  final String priority; // LOW | MEDIUM | HIGH | URGENT
  final String? resolution;
  final String? referenceId;
  final String createdAt;
  final String updatedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.resolution,
    this.referenceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'GENERAL',
      status: json['status'] ?? 'OPEN',
      priority: json['priority'] ?? 'MEDIUM',
      resolution: json['resolution'],
      referenceId: json['reference_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
