import 'package:flutter/material.dart';
import 'package:home_care/Pages/Profile/Widget/show_appoiments.dart';
import 'package:home_care/Pages/Profile/widget/dashboard_card.dart';

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
            onTap: () => showAppointments(context),
          ),
          DashboardCard('Records', Icons.folder),
          DashboardCard('Profile', Icons.account_circle_outlined),
          DashboardCard('Payments', Icons.credit_card),
        ],
      ),
    );
  }
}
