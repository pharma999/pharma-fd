import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:home_care/Helper/logger_service.dart';

/// Model for a service in the cart
class ServiceCart {
  final String serviceId;
  final String title;
  final IconData icon;
  final Color color;
  final double price;
  int quantity;

  ServiceCart({
    required this.serviceId,
    required this.title,
    required this.icon,
    required this.color,
    required this.price,
    this.quantity = 1,
  });

  /// Calculate total price for this service
  double get totalPrice => price * quantity;

  @override
  String toString() => '$title (x$quantity) - \$$totalPrice';
}

/// Shopping cart controller with GetX state management
class ServiceCartController extends GetxController {
  RxList<ServiceCart> cartItems = <ServiceCart>[].obs;
  RxDouble totalPrice = 0.0.obs;
  RxBool isLoading = false.obs;

  /// Add service to cart - prevents duplicates, increments quantity
  /// Returns true if service was added, false if quantity was incremented
  bool addService({
    required String serviceId,
    required String title,
    required IconData icon,
    required Color color,
    double price = 500.0,
  }) {
    try {
      LoggerService.info('Adding service: $title (ID: $serviceId)');

      // Check if service already exists in cart
      final existingService = cartItems.firstWhereOrNull(
        (item) => item.serviceId == serviceId,
      );

      bool isNewService = false;
      if (existingService != null) {
        // Service already exists - increment quantity only
        existingService.quantity++;
        LoggerService.info(
          'Service already in cart. Quantity increased to ${existingService.quantity}',
        );
      } else {
        // Service doesn't exist - add as new item
        cartItems.add(
          ServiceCart(
            serviceId: serviceId,
            title: title,
            icon: icon,
            color: color,
            price: price,
          ),
        );
        isNewService = true;
        LoggerService.success('New service added to cart: $title');
      }

      calculateTotal();
      return isNewService;
    } catch (e) {
      LoggerService.error('Error adding service', e);
      return false;
    }
  }

  /// Remove service completely from cart
  bool removeService(String serviceId) {
    try {
      final initialCount = cartItems.length;
      cartItems.removeWhere((item) => item.serviceId == serviceId);

      if (cartItems.length < initialCount) {
        LoggerService.info('Service removed from cart (ID: $serviceId)');
        calculateTotal();
        return true;
      }
      LoggerService.warning('Service not found in cart (ID: $serviceId)');
      return false;
    } catch (e) {
      LoggerService.error('Error removing service', e);
      return false;
    }
  }

  /// Update quantity of a service
  bool updateQuantity(String serviceId, int quantity) {
    try {
      if (quantity < 0) {
        LoggerService.warning('Invalid quantity: $quantity');
        return false;
      }

      final service = cartItems.firstWhereOrNull(
        (item) => item.serviceId == serviceId,
      );

      if (service == null) {
        LoggerService.warning('Service not found (ID: $serviceId)');
        return false;
      }

      if (quantity == 0) {
        // Remove if quantity reaches 0
        removeService(serviceId);
        LoggerService.info('Service removed (quantity set to 0)');
      } else {
        service.quantity = quantity;
        LoggerService.info('Quantity updated for $serviceId: $quantity');
        calculateTotal();
      }
      return true;
    } catch (e) {
      LoggerService.error('Error updating quantity', e);
      return false;
    }
  }

  /// Clear entire cart
  void clearCart() {
    try {
      cartItems.clear();
      totalPrice.value = 0.0;
      LoggerService.info('Cart cleared');
    } catch (e) {
      LoggerService.error('Error clearing cart', e);
    }
  }

  /// Recalculate total price
  void calculateTotal() {
    try {
      totalPrice.value = cartItems.fold(
        0.0,
        (previousValue, item) => previousValue + item.totalPrice,
      );
      LoggerService.debug('Total price calculated: \$${totalPrice.value}');
    } catch (e) {
      LoggerService.error('Error calculating total', e);
    }
  }

  /// Check if service exists in cart
  bool containsService(String serviceId) {
    return cartItems.any((item) => item.serviceId == serviceId);
  }

  /// Get service from cart
  ServiceCart? getService(String serviceId) {
    try {
      return cartItems.firstWhereOrNull((item) => item.serviceId == serviceId);
    } catch (e) {
      LoggerService.error('Error getting service', e);
      return null;
    }
  }

  // Getters
  int get cartCount => cartItems.length;

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => cartItems.isEmpty;

  bool get isNotEmpty => cartItems.isNotEmpty;
}
