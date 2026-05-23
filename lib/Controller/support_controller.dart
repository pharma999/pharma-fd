import 'package:get/get.dart';
import 'package:home_care/Api/Services/support_repository.dart';
import 'package:home_care/Model/support_model.dart';

class SupportController extends GetxController {
  final SupportRepository _repo = SupportRepository();

  RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCreating = false.obs;
  RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    isLoading.value = true;
    error.value = '';
    final result = await _repo.getMyTickets();
    result.when(
      onSuccess: (data) => tickets.assignAll(data),
      onError: (e) => error.value = e,
    );
    isLoading.value = false;
  }

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String category,
    String priority = 'MEDIUM',
    String? referenceId,
  }) async {
    isCreating.value = true;
    bool success = false;
    final result = await _repo.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      referenceId: referenceId,
    );
    result.when(
      onSuccess: (ticket) {
        tickets.insert(0, ticket);
        success = true;
      },
      onError: (e) => error.value = e,
    );
    isCreating.value = false;
    return success;
  }

  List<SupportTicket> get open =>
      tickets.where((t) => t.status == 'OPEN' || t.status == 'IN_REVIEW').toList();
  List<SupportTicket> get resolved =>
      tickets.where((t) => t.status == 'RESOLVED' || t.status == 'CLOSED').toList();
}
