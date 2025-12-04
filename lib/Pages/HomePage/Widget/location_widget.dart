import 'package:flutter/material.dart';
import 'package:home_care/Controller/profile_controller.dart';

class LocationHomeUi extends StatelessWidget {
  const LocationHomeUi({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController();
    // Example full location text
    final String fullLocation =
        "Lucknow Jankipuram Sector-H 201013 near Engineering College main gate road number five";

    // Split the string into words and take only the first 10
    final List<String> words = fullLocation.split(' ');
    final String shortLocation = words.length > 20
        ? '${words.take(10).join(' ')}...'
        : fullLocation;

    // Example dynamic notification count
    final int notificationCount = 3;

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

        // 🔹 Notification icon with badge
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // Notification button action
                print("Card has been clicked...");
              },
              icon: const Icon(
                // Icons.notifications,
                Icons.shopping_cart,
                color: Colors.black54,
                size: 25,
              ),
            ),
            if (notificationCount > 0)
              Positioned(
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
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // 🔹 Profile icon
        IconButton(
          onPressed: () {
            // Profile button action
            print("profile clicked...");
            controller.profile();
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
