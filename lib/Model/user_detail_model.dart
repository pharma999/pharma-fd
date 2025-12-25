import 'address_model.dart';

class UserDetail {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final String status;
  final String blockStatus;
  final String userService;
  final String serviceStatus;
  final Address? address1;
  final Address? address2;

  UserDetail({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.status,
    required this.blockStatus,
    required this.userService,
    required this.serviceStatus,
    this.address1,
    this.address2,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      status: json['status'],
      blockStatus: json['block_status'],
      userService: json['user_service'],
      serviceStatus: json['service_status'],
      address1: json['address_1'] != null
          ? Address.fromJson(json['address_1'])
          : null,
      address2: json['address_2'] != null
          ? Address.fromJson(json['address_2'])
          : null,
    );
  }
}
