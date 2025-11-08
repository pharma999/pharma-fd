import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickServicesPage extends StatelessWidget {
  final List<ServiceItem> services = [
    ServiceItem("Book Ambulance", Icons.local_hospital, Colors.red),
    ServiceItem("Quick Doctor", Icons.medical_services, Colors.green),
    ServiceItem("Order Medicine", Icons.medication, Colors.teal),
    ServiceItem("Physiotherapy", Icons.fitness_center, Colors.purple),
    ServiceItem("Lab Tests at Home", Icons.biotech, Colors.amber),
    ServiceItem("Nurse Visit", Icons.local_hospital_outlined, Colors.indigo),
    ServiceItem("Emergency First Aid", Icons.add_circle, Colors.deepPurple),
    ServiceItem("Nurse Visit", Icons.nature_sharp, Colors.orange),
  ];

  QuickServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.offAllNamed("/bottomAppBar"),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Quick Services",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6BC4FF), Color(0xFFE3F2FD)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // 🔍 Search bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Lucknow Jankipuran services...",
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            Text(
              "Healthcare Services",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // 🧩 Grid of services
            Expanded(
              child: GridView.builder(
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () {
                      print("Tapped on ${service.title}");
                      // TODO: Navigate to detail page or call controller.quick()
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: service.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: BottomBarPage(),
    );
  }
}

class ServiceItem {
  final String title;
  final IconData icon;
  final Color color;

  ServiceItem(this.title, this.icon, this.color);
}
