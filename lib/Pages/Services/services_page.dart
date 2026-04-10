import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Services"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Buttons Row
                const SizedBox(height: 16),

                // Location Row
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      Icon(Icons.location_on, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Lucknow Jankipuram Sector-H 201013",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: 'Search your services...',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xff6a11cb), Color(0xff2575fc)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Text(
                    "Welcome back!\nHow are you feeling today? Need any help?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Healthcare Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid of Services
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: [
                    _buildServiceCard(
                      Icons.shield_rounded,
                      "Nursing Care",
                      Colors.blue,
                      'nursing_care',
                    ),
                    _buildServiceCard(
                      Icons.monitor_heart,
                      "Physiotherapy",
                      Colors.purple,
                      'physiotherapy',
                    ),
                    _buildServiceCard(
                      Icons.favorite,
                      "Elder Care",
                      Colors.pink,
                      'elder_care',
                    ),
                    _buildServiceCard(
                      Icons.psychology,
                      "Mental Health",
                      Colors.green,
                      'mental_health',
                    ),
                    _buildServiceCard(
                      Icons.medical_services,
                      "Lab Test",
                      Colors.orange,
                      'lab_tests',
                    ),
                    _buildServiceCard(
                      Icons.warning,
                      "Emergency Help",
                      Colors.red,
                      'emergency',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    IconData icon,
    String label,
    Color color,
    String serviceId,
  ) {
    final cartController = Get.find<ServiceCartController>();
    final profController = Get.find<ServiceProfessionalsController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Label
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  radius: 22,
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF312E81),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: OutlinedButton(
                    onPressed: () {
                      // Add to Cart logic
                      cartController.addService(
                        serviceId: serviceId,
                        title: label,
                        icon: icon,
                        color: color,
                        price: 500.0,
                      );
                      Get.snackbar(
                        'Added to Cart',
                        '$label added to cart',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300, width: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: ElevatedButton(
                    onPressed: () {
                      // Book Now logic
                      profController.selectService(serviceId, label);
                      Get.snackbar(
                        'Service Selected',
                        'Showing available professionals for $label',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blue.shade600,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
