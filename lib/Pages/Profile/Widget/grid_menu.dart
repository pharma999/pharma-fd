import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Pages/Profile/Widget/show_appoiments.dart';
import 'package:home_care/Pages/Profile/widget/dashboard_card.dart';
import 'package:home_care/Pages/Profile/appointments_page.dart';
import 'package:home_care/Pages/Profile/records_page.dart';
import 'package:home_care/Pages/Profile/profile_details_page.dart';
import 'package:home_care/Pages/Profile/payments_page.dart';

class GridMenu extends StatelessWidget {
  const GridMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: [
          DashboardCard(
            'Appointments',
            Icons.calendar_today,
            onTap: () => Get.to(() => const AppointmentsPage()),
          ),
          DashboardCard(
            'Records',
            Icons.folder,
            onTap: () => Get.to(() => const RecordsPage()),
          ),
          DashboardCard(
            'Payments',
            Icons.credit_card,
            onTap: () => Get.to(() => const PaymentsPage()),
          ),
        ],
      ),
    );
  }
}
