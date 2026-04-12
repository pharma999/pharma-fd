import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/admin_model.dart';

class AdminPlansPage extends StatefulWidget {
  const AdminPlansPage({super.key});

  @override
  State<AdminPlansPage> createState() => _AdminPlansPageState();
}

class _AdminPlansPageState extends State<AdminPlansPage> {
  final ctrl = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Subscription Plans',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingPlans.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_membership,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('No subscription plans yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreateDialog(context),
                  child: const Text('Create First Plan'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.plans.length,
          itemBuilder: (_, i) =>
              _PlanCard(plan: ctrl.plans[i], ctrl: ctrl),
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final bookingsCtrl = TextEditingController(text: '10');
    final familyCtrl = TextEditingController(text: '5');
    String duration = 'MONTHLY';

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (_, setS) => AlertDialog(
          title: const Text('New Subscription Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Plan Name')),
                TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description')),
                TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (₹)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: duration,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  items: ['MONTHLY', 'QUARTERLY', 'YEARLY']
                      .map((d) =>
                          DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setS(() => duration = v!),
                ),
                TextField(
                    controller: bookingsCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Bookings')),
                TextField(
                    controller: familyCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Max Family Members')),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ctrl.createPlan({
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'duration': duration,
                  'max_bookings': int.tryParse(bookingsCtrl.text) ?? 10,
                  'max_family_members': int.tryParse(familyCtrl.text) ?? 5,
                });
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final AdminController ctrl;
  const _PlanCard({required this.plan, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: plan.isActive
                ? const Color(0xFF00897B).withValues(alpha: 0.4)
                : Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Switch(
                  value: plan.isActive,
                  activeThumbColor: const Color(0xFF00897B),
                  onChanged: (v) => ctrl.togglePlanActive(plan.id, v),
                ),
              ],
            ),
            Text('₹${plan.price.toInt()} / ${plan.duration}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00897B))),
            const SizedBox(height: 6),
            Text(plan.description,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: plan.features
                  .map((f) => Chip(
                        label: Text(f,
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFF00897B)
                            .withValues(alpha: 0.08),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bookmark, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${plan.maxBookings} bookings',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 16),
                const Icon(Icons.family_restroom,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${plan.maxFamilyMembers} family',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ctrl.deletePlan(plan.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
