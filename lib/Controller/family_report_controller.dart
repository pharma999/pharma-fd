import 'package:get/get.dart';
import 'package:home_care/Api/Services/medical_record_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/family_member_model.dart';
import 'package:home_care/Model/medical_record_model.dart';

class FamilyReportController extends GetxController {
  final MedicalRecordRepository _repo = MedicalRecordRepository();

  RxList<FamilyMemberModel> familyMembers = <FamilyMemberModel>[].obs;
  RxList<MedicalRecord> medicalRecords = <MedicalRecord>[].obs;
  // Per-member records: memberId → list
  final RxMap<String, List<MedicalRecord>> memberRecords =
      <String, List<MedicalRecord>>{}.obs;

  RxBool isLoadingMembers = false.obs;
  RxBool isLoadingRecords = false.obs;
  RxBool isUploading = false.obs;
  RxBool isLoadingMemberRecords = false.obs;

  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    loadFamilyMembers();
    loadMedicalRecords();
  }

  Future<void> loadFamilyMembers() async {
    isLoadingMembers.value = true;
    errorMessage.value = '';
    final result = await _repo.getFamilyMembers();
    result.when(
      onSuccess: (members) => familyMembers.assignAll(members),
      onError: (e) {
        errorMessage.value = e;
        LoggerService.error('Load family members failed', e);
      },
    );
    isLoadingMembers.value = false;
  }

  Future<void> loadMedicalRecords() async {
    isLoadingRecords.value = true;
    final result = await _repo.getMyRecords();
    result.when(
      onSuccess: (records) => medicalRecords.assignAll(records),
      onError: (e) => LoggerService.error('Load records failed', e),
    );
    isLoadingRecords.value = false;
  }

  Future<bool> addFamilyMember({
    required String name,
    required String relation,
    String gender = '',
    String dateOfBirth = '',
    String bloodGroup = '',
  }) async {
    final result = await _repo.addFamilyMember(
      name: name,
      relation: relation,
      gender: gender,
      dateOfBirth: dateOfBirth,
      bloodGroup: bloodGroup,
    );
    bool success = false;
    result.when(
      onSuccess: (member) {
        familyMembers.add(member);
        success = true;
      },
      onError: (e) {
        errorMessage.value = e;
        LoggerService.error('Add family member failed', e);
      },
    );
    return success;
  }

  /// Upload file then create medical record. Returns true on success.
  Future<bool> uploadReport({
    required String filePath,
    required String title,
    required String recordType,
    required String recordDate,
    String description = '',
    String doctorName = '',
    String hospitalName = '',
  }) async {
    isUploading.value = true;
    try {
      // Step 1: upload file → get URL
      final uploadResult = await _repo.uploadFile(filePath);
      String fileUrl = '';
      bool uploadOk = false;
      uploadResult.when(
        onSuccess: (url) {
          fileUrl = url;
          uploadOk = true;
        },
        onError: (e) {
          errorMessage.value = e;
        },
      );
      if (!uploadOk) return false;

      // Step 2: create medical record with the URL
      final recordResult = await _repo.addRecord(
        recordType: recordType,
        title: title,
        recordDate: recordDate,
        description: description,
        fileUrl: fileUrl,
        doctorName: doctorName,
        hospitalName: hospitalName,
      );
      bool recordOk = false;
      recordResult.when(
        onSuccess: (record) {
          medicalRecords.insert(0, record);
          recordOk = true;
        },
        onError: (e) {
          errorMessage.value = e;
        },
      );
      return recordOk;
    } finally {
      isUploading.value = false;
    }
  }

  /// Load records for a specific family member.
  Future<void> loadMemberRecords(String memberId) async {
    isLoadingMemberRecords.value = true;
    final result = await _repo.getMemberRecords(memberId);
    result.when(
      onSuccess: (records) {
        memberRecords[memberId] = records;
        memberRecords.refresh();
      },
      onError: (e) => errorMessage.value = e,
    );
    isLoadingMemberRecords.value = false;
  }

  /// Upload a report for a specific family member.
  Future<bool> uploadReportForMember({
    required String familyMemberId,
    required String filePath,
    required String title,
    required String recordType,
    required String recordDate,
    String description = '',
    String doctorName = '',
    String hospitalName = '',
  }) async {
    isUploading.value = true;
    try {
      final uploadResult = await _repo.uploadFile(filePath);
      String fileUrl = '';
      bool uploadOk = false;
      uploadResult.when(
        onSuccess: (url) { fileUrl = url; uploadOk = true; },
        onError: (e) => errorMessage.value = e,
      );
      if (!uploadOk) return false;

      final recordResult = await _repo.addMemberRecord(
        familyMemberId: familyMemberId,
        recordType: recordType,
        title: title,
        recordDate: recordDate,
        description: description,
        fileUrl: fileUrl,
        doctorName: doctorName,
        hospitalName: hospitalName,
      );
      bool recordOk = false;
      recordResult.when(
        onSuccess: (record) {
          final current = List<MedicalRecord>.from(
              memberRecords[familyMemberId] ?? []);
          current.insert(0, record);
          memberRecords[familyMemberId] = current;
          memberRecords.refresh();
          recordOk = true;
        },
        onError: (e) => errorMessage.value = e,
      );
      return recordOk;
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete a record and remove from member cache.
  Future<void> deleteMemberRecord(String recordId, String memberId) async {
    final result = await _repo.deleteRecord(recordId);
    result.when(
      onSuccess: (_) {
        final list = memberRecords[memberId] ?? [];
        memberRecords[memberId] = list.where((r) => r.recordId != recordId).toList();
        memberRecords.refresh();
      },
      onError: (e) => errorMessage.value = e,
    );
  }

  Future<void> deleteRecord(String recordId) async {
    final result = await _repo.deleteRecord(recordId);
    result.when(
      onSuccess: (_) => medicalRecords.removeWhere((r) => r.recordId == recordId),
      onError: (e) => errorMessage.value = e,
    );
  }

  int get memberCount => familyMembers.length;
  int get recordCount => medicalRecords.length;
}
