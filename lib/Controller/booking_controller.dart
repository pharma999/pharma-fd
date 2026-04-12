import 'package:get/get.dart';
import 'package:home_care/Api/Services/booking_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/booking_model.dart';

/// Manages bookings and payment flow
class BookingController extends GetxController {
  final BookingRepository _repo = BookingRepository();

  RxList<BookingModel> bookings = <BookingModel>[].obs;
  RxList<PaymentModel> payments = <PaymentModel>[].obs;
  Rx<BookingModel?> selectedBooking = Rx<BookingModel?>(null);

  RxBool isLoadingBookings = false.obs;
  RxBool isCreating = false.obs;
  RxBool isProcessingPayment = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  List<BookingModel> get activeBookings =>
      bookings.where((b) => b.isActive).toList();

  List<BookingModel> get pastBookings =>
      bookings.where((b) => !b.isActive).toList();

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
          LoggerService.success('Booking created: ${booking.id}');
          Get.snackbar('Success', 'Booking created successfully!');
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
      // Step 1 – initiate
      final initResult = await _repo.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
      );

      // Step 2 – confirm if initiation succeeded
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
        // In a real app: open payment gateway here, then confirm
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
