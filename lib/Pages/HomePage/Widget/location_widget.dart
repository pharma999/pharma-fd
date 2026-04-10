import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Controller/service_cart_controller.dart';

class LocationHomeUi extends StatelessWidget {
  const LocationHomeUi({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController();
    final ServiceCartController cartController = Get.find<ServiceCartController>();

    // Example full location text
    final String fullLocation =
        "Lucknow Jankipuram Sector-H 201013 near Engineering College main gate road number five";

    // Split the string into words and take only the first 10
    final List<String> words = fullLocation.split(' ');
    final String shortLocation = words.length > 20
        ? '${words.take(10).join(' ')}...'
        : fullLocation;

    return Row(
      children: [
        const Icon(Icons.home, size: 20, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            shortLocation,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black54),
        const SizedBox(width: 10),

        // 🔹 Notification icon with dynamic badge
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Get.offAllNamed("/cart");
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.black54,
                size: 25,
              ),
            ),
            Obx(
              () {
                if (cartController.totalItems > 0) {
                  return Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartController.totalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),

        // 🔹 Profile icon
        IconButton(
          onPressed: () {
            Get.offAllNamed("/profile");
          },
          icon: const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.black12,
            child: Icon(Icons.person, size: 18, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
