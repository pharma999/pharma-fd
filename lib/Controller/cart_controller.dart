import 'package:get/get.dart';
import 'package:home_care/Api/Services/service_repository.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Model/service_model.dart';

/// Manages shopping cart state with live backend sync
class CartController extends GetxController {
  final ServiceRepository _repo = ServiceRepository();

  RxList<CartItem> items = <CartItem>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCheckingOut = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final result = await _repo.getCart();
      result.when(
        onSuccess: (data) {
          items.value = data;
          LoggerService.success('Cart loaded: ${data.length} items');
        },
        onError: (err) {
          errorMessage.value = err;
          LoggerService.error('Failed to load cart', err);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart({
    required String serviceId,
    int quantity = 1,
    String? professionalId,
    String? scheduledAt,
  }) async {
    final result = await _repo.addToCart(
      serviceId: serviceId,
      quantity: quantity,
      professionalId: professionalId,
      scheduledAt: scheduledAt,
    );
    bool success = false;
    result.when(
      onSuccess: (item) {
        success = true;
        fetchCart(); // refresh full cart from server
        Get.snackbar('Added', 'Item added to cart');
      },
      onError: (err) {
        Get.snackbar('Error', err);
      },
    );
    return success;
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity < 1) {
      await removeItem(itemId);
      return;
    }
    final result = await _repo.updateCartQuantity(itemId, quantity);
    result.when(
      onSuccess: (_) => fetchCart(),
      onError: (err) => Get.snackbar('Error', err),
    );
  }

  Future<void> removeItem(String itemId) async {
    final result = await _repo.removeFromCart(itemId);
    result.when(
      onSuccess: (_) {
        items.removeWhere((item) => item.id == itemId);
        LoggerService.info('Item removed from cart: $itemId');
      },
      onError: (err) => Get.snackbar('Error', err),
    );
  }

  Future<void> clearCart() async {
    final result = await _repo.clearCart();
    result.when(
      onSuccess: (_) => items.clear(),
      onError: (err) => Get.snackbar('Error', err),
    );
  }

  Future<bool> checkout({
    required String address,
    required String scheduledAt,
    String? notes,
  }) async {
    try {
      isCheckingOut.value = true;
      final result = await _repo.checkoutCart(
        address: address,
        scheduledAt: scheduledAt,
        notes: notes,
      );
      bool success = false;
      result.when(
        onSuccess: (_) {
          success = true;
          items.clear();
          LoggerService.success('Checkout successful');
          Get.snackbar('Success', 'Booking confirmed!');
        },
        onError: (err) {
          Get.snackbar('Error', err);
          LoggerService.error('Checkout failed', err);
        },
      );
      return success;
    } finally {
      isCheckingOut.value = false;
    }
  }
}
