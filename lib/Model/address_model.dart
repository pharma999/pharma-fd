class Address {
  final String houseNumber;
  final String street;
  final String landmark;
  final String pinCode;
  final String latitude;
  final String longitude;
  final bool isPrimary;

  Address({
    required this.houseNumber,
    required this.street,
    required this.landmark,
    required this.pinCode,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      houseNumber: json['house_number'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      pinCode: json['pin_code'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }
}
