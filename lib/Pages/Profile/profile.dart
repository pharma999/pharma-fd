import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/images_config.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Pages/Profile/Widget/personal_details_widget.dart';
import 'package:home_care/Pages/Profile/widget/grid_menu.dart';
import 'package:home_care/Pages/Profile/widget/info_card.dart';
import 'package:home_care/Pages/Profile/widget/section_title.dart';
import 'package:home_care/Pages/Profile/widget/settings_tile.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  // const Profile({super.key});
  // final ProfileController controller = Get.put(ProfileController());
  // ✅ Inject controller
  final ProfileController controller = Get.put(ProfileController());

  // const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Remove elevation and shadow to prevent color distortion
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            Colors.transparent, // Make background transparent to see gradient
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/bottomAppBar'),
        ),
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.offAllNamed('/bottomAppBar'),
          ),
        ],
        // 2. The gradient here needs to match the header exactly
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 20),
            const SectionTitle(title: 'My Health'),
            _healthTile(context),
            const SectionTitle(title: 'Dashboard'),
            const GridMenu(),
            PersonalDetailsWidget(user: controller.user),
            const SectionTitle(title: 'Settings'),
            const SettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
            ),
            const SettingsTile(icon: Icons.lock, title: 'Privacy & Security'),
            const SettingsTile(icon: Icons.help, title: 'Help & Support'),
            const SettingsTile(
              icon: Icons.logout,
              title: 'Log Out',
              color: Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple, Colors.orange]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage(AssetsImage.profileImage),
          ),
          SizedBox(height: 10),
          Text(
            'Alex Morgan',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Lucknow Jankipuram Sector-H',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoCard(title: 'Age', value: '24'),
              InfoCard(title: 'Blood', value: 'B+'),
              InfoCard(title: 'Weight', value: '72kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.favorite, color: Colors.green),
      title: const Text('Heart Rate'),
      subtitle: const Text('78 bpm · Normal'),
      trailing: TextButton(
        onPressed: () => _showHealthDetails(context),
        child: const Text('View'),
      ),
    );
  }
}

void _showHealthDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Heart Rate Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _detailRow("Current", "78 bpm"),
            _detailRow("Status", "Normal"),
            _detailRow("Average (7 days)", "75 bpm"),
            _detailRow("Max Recorded", "102 bpm"),
            _detailRow("Min Recorded", "60 bpm"),
            _detailRow("Last Updated", "Today, 10:45 AM"),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _detailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
