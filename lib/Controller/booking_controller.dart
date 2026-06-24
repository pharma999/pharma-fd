import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/booking_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/booking_model.dart';
import 'package:home_care/Pages/Bookings/booking_tracking_page.dart';
import 'package:home_care/Pages/Call/incoming_call_page.dart';
import 'package:home_care/utils/token_storage.dart';

/// Manages bookings, payment flow, and the global WebSocket listener that
/// auto-navigates the patient to the tracking screen the instant a booking
/// status changes to ACCEPTED — no user interaction required.
class BookingController extends GetxController {
  final BookingRepository _repo = BookingRepository();

  // ── Booking list ──────────────────────────────────────────────────────────
  RxList<BookingModel> bookings = <BookingModel>[].obs;
  RxList<PaymentModel> payments = <PaymentModel>[].obs;
  Rx<BookingModel?> selectedBooking = Rx<BookingModel?>(null);

  RxBool isLoadingBookings = false.obs;
  RxBool isCreating = false.obs;
  RxBool isProcessingPayment = false.obs;
  RxString errorMessage = ''.obs;

  // ── Active booking (banner on home page) ──────────────────────────────────
  final activeBookingId = ''.obs;
  final activeBookingStatus = ''.obs;
  final activeBookingServiceName = ''.obs;

  // ── WebSocket for auto-navigation ─────────────────────────────────────────
  WebSocket? _ws;
  Timer? _wsReconnect;
  bool _wsDisposed = false;
  bool _navigatedToTracking = false; // prevent double-push

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
    _connectWS();
  }

  @override
  void onClose() {
    _wsDisposed = true;
    _ws?.close();
    _wsReconnect?.cancel();
    super.onClose();
  }

  // ── Derived getters ───────────────────────────────────────────────────────

  /// PENDING + ASSIGNED bookings (waiting for provider)
  List<BookingModel> get pendingBookings =>
      bookings.where((b) => b.isPending).toList();

  /// ACCEPTED + IN_PROGRESS (provider assigned and active)
  List<BookingModel> get activeBookings =>
      bookings.where((b) => b.isActive).toList();

  /// IN_PROGRESS only — shown as the top "Live" card
  BookingModel? get liveBooking =>
      bookings.firstWhereOrNull((b) => b.isInProgress);

  /// ACCEPTED — provider en route
  List<BookingModel> get acceptedBookings =>
      bookings.where((b) => b.isAccepted).toList();

  List<BookingModel> get completedBookings =>
      bookings.where((b) => b.isCompleted).toList();

  List<BookingModel> get cancelledBookings =>
      bookings.where((b) => b.isCancelled).toList();

  List<BookingModel> get pastBookings =>
      bookings.where((b) => b.isCompleted || b.isCancelled).toList();

  // ── WebSocket ─────────────────────────────────────────────────────────────

  Future<void> _connectWS() async {
    if (_wsDisposed) return;
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        _scheduleReconnect();
        return;
      }
      final wsBase = ApiConfig.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceAll('/api', '');
      final uri =
          '$wsBase/api/ws?token=${Uri.encodeComponent(token)}';
      _ws = await WebSocket.connect(uri).timeout(const Duration(seconds: 10));
      if (_wsDisposed) {
        _ws?.close();
        return;
      }
      _ws!.listen(
        _onWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
      LoggerService.info('BookingController WS connected');
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_wsDisposed) return;
    _ws = null;
    _wsReconnect?.cancel();
    _wsReconnect = Timer(const Duration(seconds: 5), () {
      if (!_wsDisposed) _connectWS();
    });
  }

  void _onWsMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String? ?? '';

      // ── booking_update: provider accepted / started / completed ───────────
      if (type == 'booking_update') {
        final rawP = msg['payload'];
        final p = rawP is String
            ? jsonDecode(rawP) as Map<String, dynamic>
            : Map<String, dynamic>.from(rawP as Map);

        final status      = p['status'] as String? ?? '';
        final bookingId   = p['booking_id'] as String? ?? '';
        final serviceName = p['service_name'] as String? ?? activeBookingServiceName.value;

        if (status.isNotEmpty) {
          activeBookingStatus.value = status;
        }
        if (bookingId.isNotEmpty) {
          activeBookingId.value = bookingId;
        }
        if (serviceName.isNotEmpty) {
          activeBookingServiceName.value = serviceName;
        }

        // ── AUTO-OPEN tracking screen when provider accepts ────────────────
        if (status == 'ACCEPTED' && bookingId.isNotEmpty) {
          _autoOpenTracking(bookingId, serviceName, status);
        }

        // Refresh local booking list silently
        fetchMyBookings();
      }

      // ── booking_status: incoming booking for THIS user as a provider ──────
      // (patient app users won't normally get this unless they're also a nurse)

      // ── call_invite: provider is calling this patient ─────────────────────
      if (type == 'call_invite') {
        final rawP = msg['payload'];
        final p = rawP is String
            ? jsonDecode(rawP) as Map<String, dynamic>
            : Map<String, dynamic>.from(rawP as Map);

        final callId      = p['call_id']     as String? ?? '';
        final callerId    = p['caller_id']   as String? ?? '';
        final callerName  = p['caller_name'] as String? ?? 'Provider';
        final bookingId   = p['booking_id']  as String? ?? '';

        if (callId.isNotEmpty && callerId.isNotEmpty) {
          // Small delay so any current route settles before pushing full-screen
          Future.delayed(const Duration(milliseconds: 200), () {
            Get.to(
              () => IncomingCallPage(
                callId:       callId,
                callerId:     callerId,
                callerName:   callerName,
                bookingId:    bookingId,
                remoteUserId: callerId,
              ),
              fullscreenDialog: true,
              transition: Transition.fade,
            );
          });
        }
      }

      // ── call_ended: remote party hung up ─────────────────────────────────
      // VideoCallPage listens for this directly via its own WS connection
      // (CallService._onWsMessage). No navigation needed here.
    } catch (_) {}
  }

  void _autoOpenTracking(
      String bookingId, String serviceName, String status) {
    if (_navigatedToTracking) return;
    _navigatedToTracking = true;

    // Slight delay so any current transition (snackbar, confirm dialog) settles
    Future.delayed(const Duration(milliseconds: 400), () {
      _navigatedToTracking = false;
      final page = BookingTrackingPage(
        bookingId: bookingId,
        serviceName:
            serviceName.isNotEmpty ? serviceName : 'Your Booking',
        status: status,
      );
      // Use Get.to so the back button returns to wherever the patient was
      Get.to(() => page,
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 400));
    });
  }

  // ── REST booking operations ───────────────────────────────────────────────

  Future<void> fetchMyBookings({String? status}) async {
    try {
      isLoadingBookings.value = true;
      errorMessage.value = '';
      final result = await _repo.getMyBookings(
        status: status?.isEmpty == true ? null : status,
      );
      result.when(
        onSuccess: (data) {
          bookings.value = data;
          // Sync active booking observable so home-page banner stays fresh
          final active = data.firstWhereOrNull((b) => b.isActive);
          if (active != null) {
            activeBookingId.value = active.id;
            activeBookingStatus.value = active.status;
          } else {
            activeBookingId.value = '';
            activeBookingStatus.value = '';
          }
          LoggerService.success('Loaded ${data.length} bookings');
        },
        onError: (err) => errorMessage.value = err,
      );
    } finally {
      isLoadingBookings.value = false;
    }
  }

  Future<bool> createBooking({
    required String serviceId,
    String? professionalId,
    required String bookingType,
    String? scheduledAt,
    required String patientAddress,
    double? patientLatitude,
    double? patientLongitude,
    String? notes,
  }) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';
      final result = await _repo.createBooking(
        serviceId: serviceId,
        professionalId: professionalId,
        bookingType: bookingType,
        scheduledAt: scheduledAt,
        patientAddress: patientAddress,
        patientLatitude: patientLatitude,
        patientLongitude: patientLongitude,
        notes: notes,
      );
      bool success = false;
      result.when(
        onSuccess: (booking) {
          success = true;
          bookings.add(booking);
          selectedBooking.value = booking;
          activeBookingId.value = booking.id;
          activeBookingStatus.value = booking.status;
          LoggerService.success('Booking created: ${booking.id}');
        },
        onError: (err) {
          errorMessage.value = err;
          Get.snackbar('Error', err);
        },
      );
      return success;
    } finally {
      isCreating.value = false;
    }
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final result = await _repo.cancelBooking(bookingId, reason: reason);
    bool success = false;
    result.when(
      onSuccess: (_) {
        success = true;
        bookings.removeWhere((b) => b.id == bookingId);
        if (activeBookingId.value == bookingId) {
          activeBookingId.value = '';
          activeBookingStatus.value = '';
        }
        Get.snackbar('Cancelled', 'Booking cancelled');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
    return success;
  }

  Future<void> fetchPaymentHistory() async {
    final result = await _repo.getPaymentHistory();
    result.when(
      onSuccess: (data) => payments.value = data,
      onError: (err) => errorMessage.value = err,
    );
  }

  Future<bool> processPayment({
    required String bookingId,
    required double amount,
    String paymentMethod = 'CARD',
  }) async {
    try {
      isProcessingPayment.value = true;
      final initResult = await _repo.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      bool success = false;
      String? paymentId;
      String? initError;
      initResult.when(
        onSuccess: (data) => paymentId = data['payment_id'] as String?,
        onError: (err) => initError = err,
      );
      if (initError != null) {
        Get.snackbar('Error', initError!);
        return false;
      }
      if (paymentId != null && paymentId!.isNotEmpty) {
        final confirmResult = await _repo.confirmPayment(
          paymentId: paymentId!,
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        );
        confirmResult.when(
          onSuccess: (_) {
            success = true;
            fetchMyBookings();
            Get.snackbar('Payment', 'Payment successful!');
          },
          onError: (err) => Get.snackbar('Error', err),
        );
      }
      return success;
    } finally {
      isProcessingPayment.value = false;
    }
  }
}
