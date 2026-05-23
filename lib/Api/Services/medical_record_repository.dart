import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Core/api_result.dart';
import 'package:home_care/Api/Config/api_endpoints.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Helper/exception_handler.dart';
import 'package:home_care/Model/medical_record_model.dart';
import 'package:home_care/Model/family_member_model.dart';

class MedicalRecordRepository {
  final ApiClient _apiClient = ApiClient();

  /// Upload a file first and return the URL.
  Future<ApiResult<String>> uploadFile(String filePath) async {
    try {
      LoggerService.info('Uploading file: $filePath');
      final response = await _apiClient.uploadFile(filePath);
      final map = response as Map<String, dynamic>;
      final url = (map['data'] as Map<String, dynamic>?)?['url'] as String? ?? '';
      if (url.isEmpty) throw Exception('No URL returned from upload');
      LoggerService.success('File uploaded: $url');
      return Success(url);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('File upload failed', msg);
      return Error(msg);
    }
  }

  /// Add a medical record (file_url comes from uploadFile).
  Future<ApiResult<MedicalRecord>> addRecord({
    required String recordType,
    required String title,
    required String recordDate,
    String description = '',
    String fileUrl = '',
    String doctorName = '',
    String hospitalName = '',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.uploadMedicalRecord,
        {
          'record_type': recordType,
          'title': title,
          'record_date': recordDate,
          'description': description,
          'file_url': fileUrl,
          'doctor_name': doctorName,
          'hospital_name': hospitalName,
        },
        requiresAuth: true,
      );
      final data = _extract(response);
      return Success(MedicalRecord.fromJson(data));
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Add record failed', msg);
      return Error(msg);
    }
  }

  /// Fetch the logged-in user's medical records.
  Future<ApiResult<List<MedicalRecord>>> getMyRecords() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.medicalRecords,
        requiresAuth: true,
      );
      final map = response as Map<String, dynamic>;
      final list = (map['data'] as List<dynamic>?) ?? [];
      final records = list
          .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(records);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Get records failed', msg);
      return Error(msg);
    }
  }

  /// Delete a record by ID.
  Future<ApiResult<void>> deleteRecord(String recordId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deleteMedicalRecord(recordId),
        requiresAuth: true,
      );
      return Success(null);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Delete record failed', msg);
      return Error(msg);
    }
  }

  /// Fetch family members for the logged-in user.
  Future<ApiResult<List<FamilyMemberModel>>> getFamilyMembers() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.familyMembers,
        requiresAuth: true,
      );
      final map = response as Map<String, dynamic>;
      final list = (map['data'] as List<dynamic>?) ?? [];
      final members = list
          .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(members);
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Get family members failed', msg);
      return Error(msg);
    }
  }

  /// Add a family member.
  Future<ApiResult<FamilyMemberModel>> addFamilyMember({
    required String name,
    required String relation,
    String gender = '',
    String dateOfBirth = '',
    String bloodGroup = '',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addFamilyMember,
        {
          'name': name,
          'relation': relation,
          if (gender.isNotEmpty) 'gender': gender,
          if (dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
          if (bloodGroup.isNotEmpty) 'blood_group': bloodGroup,
        },
        requiresAuth: true,
      );
      final data = _extract(response);
      return Success(FamilyMemberModel.fromJson(data));
    } catch (e) {
      final msg = ExceptionHandler.getErrorMessage(e);
      LoggerService.error('Add family member failed', msg);
      return Error(msg);
    }
  }

  /// Fetch medical records for a specific family member.
  Future<ApiResult<List<MedicalRecord>>> getMemberRecords(String memberId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.familyMedicalRecords(memberId),
        requiresAuth: true,
      );
      final map = response as Map<String, dynamic>;
      final list = (map['data'] as List<dynamic>?) ?? [];
      return Success(list
          .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  /// Upload a report for a specific family member.
  Future<ApiResult<MedicalRecord>> addMemberRecord({
    required String familyMemberId,
    required String recordType,
    required String title,
    required String recordDate,
    String description = '',
    String fileUrl = '',
    String doctorName = '',
    String hospitalName = '',
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.uploadMedicalRecord,
        {
          'family_member_id': familyMemberId,
          'record_type': recordType,
          'title': title,
          'record_date': recordDate,
          'description': description,
          'file_url': fileUrl,
          'doctor_name': doctorName,
          'hospital_name': hospitalName,
        },
        requiresAuth: true,
      );
      return Success(MedicalRecord.fromJson(_extract(response)));
    } catch (e) {
      return Error(ExceptionHandler.getErrorMessage(e));
    }
  }

  Map<String, dynamic> _extract(dynamic response) {
    final map = response as Map<String, dynamic>;
    if (map['data'] is Map<String, dynamic>) return map['data'];
    return map;
  }
}
