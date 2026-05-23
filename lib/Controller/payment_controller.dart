import 'package:get/get.dart';
import 'package:home_care/Api/Services/payment_repository.dart';
import 'package:home_care/Model/payment_model.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repo = PaymentRepository();

  RxList<PaymentModel> payments = <PaymentModel>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    error.value = '';
    final result = await _repo.getHistory();
    result.when(
      onSuccess: (data) => payments.assignAll(data),
      onError: (e) => error.value = e,
    );
    isLoading.value = false;
  }

  List<PaymentModel> get paid => payments.where((p) => p.isPaid).toList();
  List<PaymentModel> get pending => payments.where((p) => p.isPending).toList();

  double get totalSpent =>
      paid.fold(0, (sum, p) => sum + p.amount);

  double get totalPending =>
      pending.fold(0, (sum, p) => sum + p.amount);
}
