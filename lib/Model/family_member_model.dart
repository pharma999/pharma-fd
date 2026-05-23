class FamilyMemberModel {
  final String familyMemberId;
  final String patientUserId;
  final String? familyUserId;
  final String name;
  final String relation;
  final String gender;
  final String dateOfBirth;
  final String bloodGroup;
  final String profileImage;
  final String accessLevel;
  final bool alertsEnabled;

  FamilyMemberModel({
    required this.familyMemberId,
    required this.patientUserId,
    this.familyUserId,
    required this.name,
    required this.relation,
    required this.gender,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.profileImage,
    required this.accessLevel,
    required this.alertsEnabled,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      familyMemberId: json['family_member_id'] ?? '',
      patientUserId: json['patient_user_id'] ?? '',
      familyUserId: json['family_user_id'],
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      profileImage: json['profile_image'] ?? '',
      accessLevel: json['access_level'] ?? 'VIEW',
      alertsEnabled: json['alerts_enabled'] ?? false,
    );
  }
}
