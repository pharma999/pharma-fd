import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/service_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/utils/token_storage.dart';

/// Drives the professionals section on the home page.
/// Data is loaded from the backend — no hardcoded entries.
class ServiceProfessionalsController extends GetxController
    with WidgetsBindingObserver {
  final ServiceRepository _repo = ServiceRepository();

  RxList<ProfessionalModel> professionals = <ProfessionalModel>[].obs;
  RxList<ProfessionalModel> advertisedProfessionals = <ProfessionalModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  RxString searchQuery = ''.obs;
  RxString selectedCategoryId = ''.obs;
  RxString selectedCategoryName = ''.obs;
  RxString selectedZoneId = ''.obs;

  Timer? _refreshTimer;
  WebSocket? _ws;
  Timer? _wsReconnect;
  bool _wsDisposed = false;

  List<ProfessionalModel> get filtered {
    var list = professionals.toList();
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.experience.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  /// Alias used by services pages — same as [filtered].
  List<ProfessionalModel> get filteredProfessionals => filtered;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initIfLoggedIn();
    // Poll every 5 s as fallback when WS is disconnected
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_ws == null) _silentRefresh();
    });
  }

  @override
  void onClose() {
    _wsDisposed = true;
    _ws?.close();
    _wsReconnect?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> _connectWS() async {
    if (_wsDisposed) return;
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return;
      final wsBase = ApiConfig.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceAll('/api', '');
      final uri = '$wsBase/api/ws?token=${Uri.encodeComponent(token)}';
      _ws = await WebSocket.connect(uri).timeout(const Duration(seconds: 10));
      if (_wsDisposed) { _ws?.close(); return; }
      _ws!.listen(
        _onWsMessage,
        onError: (_) => _scheduleWsReconnect(),
        onDone: _scheduleWsReconnect,
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleWsReconnect();
    }
  }

  void _scheduleWsReconnect() {
    if (_wsDisposed) return;
    _wsReconnect?.cancel();
    _wsReconnect = Timer(const Duration(seconds: 2), () {
      if (!_wsDisposed) _connectWS();
    });
  }

  void _onWsMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['type'] == 'provider_availability') {
        final p = msg['payload'];
        final Map<String, dynamic> payload = p is String
            ? jsonDecode(p) as Map<String, dynamic>
            : Map<String, dynamic>.from(p as Map);
        final providerId  = payload['provider_id']  as String? ?? '';
        final isAvailable = payload['is_available'] as bool? ?? false;

        // Update professionals list in-place
        final idx = professionals.indexWhere((p) => p.id == providerId);
        if (idx != -1) {
          final old = professionals[idx];
          professionals[idx] = ProfessionalModel(
            id: old.id, userId: old.userId, serviceId: old.serviceId,
            name: old.name, profileImage: old.profileImage,
            rating: old.rating, totalReviews: old.totalReviews,
            price: old.price, experience: old.experience,
            skills: old.skills, isAvailable: isAvailable,
            isAdvertised: old.isAdvertised, roleName: old.roleName,
            serviceNameVal: old.serviceNameVal, zoneId: old.zoneId,
            zoneName: old.zoneName, bio: old.bio,
            qualification: old.qualification, yearsExp: old.yearsExp,
            durationMins: old.durationMins, hourlyRate: old.hourlyRate,
            timeStart: old.timeStart, timeEnd: old.timeEnd,
          );
          professionals.refresh();
        }
        // Also update advertised list
        final aidx = advertisedProfessionals.indexWhere((p) => p.id == providerId);
        if (aidx != -1) {
          final old = advertisedProfessionals[aidx];
          advertisedProfessionals[aidx] = ProfessionalModel(
            id: old.id, userId: old.userId, serviceId: old.serviceId,
            name: old.name, profileImage: old.profileImage,
            rating: old.rating, totalReviews: old.totalReviews,
            price: old.price, experience: old.experience,
            skills: old.skills, isAvailable: isAvailable,
            isAdvertised: old.isAdvertised, roleName: old.roleName,
            serviceNameVal: old.serviceNameVal, zoneId: old.zoneId,
            zoneName: old.zoneName, bio: old.bio,
            qualification: old.qualification, yearsExp: old.yearsExp,
            durationMins: old.durationMins, hourlyRate: old.hourlyRate,
            timeStart: old.timeStart, timeEnd: old.timeEnd,
          );
          advertisedProfessionals.refresh();
        }
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  Future<void> _silentRefresh() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) return;
    try {
      final r1 = await _repo.getProfessionals('',
          zoneId: selectedZoneId.value.isEmpty ? null : selectedZoneId.value);
      r1.when(onSuccess: (d) => professionals.value = d, onError: (_) {});
      final r2 = await _repo.getProfessionals('', advertised: true);
      r2.when(onSuccess: (d) => advertisedProfessionals.value = d, onError: (_) {});
    } catch (_) {}
  }

  Future<void> _initIfLoggedIn() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (loggedIn) {
      fetchAll();
      fetchAdvertised();
      _connectWS();
    }
  }

  /// Load all available professionals (no service filter).
  Future<void> fetchAll({String? zoneId}) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _repo.getProfessionals('',
          zoneId: zoneId ?? (selectedZoneId.value.isEmpty ? null : selectedZoneId.value));
      result.when(
        onSuccess: (data) {
          professionals.value = data;
          LoggerService.success('Loaded ${data.length} professionals');
        },
        onError: (err) {
          error.value = err;
          LoggerService.error('Professionals load failed', err);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load only advertised professionals for the Featured section on the home page.
  Future<void> fetchAdvertised() async {
    try {
      final result = await _repo.getProfessionals('', advertised: true);
      result.when(
        onSuccess: (data) => advertisedProfessionals.value = data,
        onError: (_) {},
      );
    } catch (_) {}
  }

  /// Filter professionals by category / service when user taps a category chip.
  Future<void> filterByCategory(String categoryId, String categoryName,
      {String? zoneId}) async {
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _repo.getProfessionals(categoryId,
          zoneId: zoneId ?? (selectedZoneId.value.isEmpty ? null : selectedZoneId.value));
      result.when(
        onSuccess: (data) => professionals.value = data,
        onError: (err) => error.value = err,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Show all professionals (clear category filter).
  void clearFilter() {
    selectedCategoryId.value = '';
    selectedCategoryName.value = '';
    fetchAll();
  }

  /// Filter professionals by a specific service name and optional zone.
  Future<void> selectService(String serviceId, String label, {String? zoneId}) async {
    selectedCategoryId.value = serviceId;
    selectedCategoryName.value = label;
    if (zoneId != null) selectedZoneId.value = zoneId;
    try {
      isLoading.value = true;
      error.value = '';
      final result = await _repo.getProfessionals(label,
          zoneId: zoneId ?? (selectedZoneId.value.isEmpty ? null : selectedZoneId.value));
      result.when(
        onSuccess: (data) => professionals.value = data,
        onError: (err) => error.value = err,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Live search — filters the local list, no extra API call.
  void search(String query) {
    searchQuery.value = query;
  }
}
