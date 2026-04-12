import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/emergency_model.dart';

class AdminEmergenciesPage extends StatefulWidget {
  const AdminEmergenciesPage({super.key});

  @override
  State<AdminEmergenciesPage> createState() => _AdminEmergenciesPageState();
}

class _AdminEmergenciesPageState extends State<AdminEmergenciesPage> {
  final ctrl = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchActiveEmergencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F3),
      appBar: AppBar(
        title: const Text('Active Emergencies',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: ctrl.fetchActiveEmergencies,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingEmergencies.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.activeEmergencies.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.green.shade400),
                const SizedBox(height: 12),
                const Text('No active emergencies',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchActiveEmergencies,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.activeEmergencies.length,
            itemBuilder: (_, i) =>
                _EmergencyCard(e: ctrl.activeEmergencies[i], ctrl: ctrl),
          ),
        );
      }),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final EmergencyModel e;
  final AdminController ctrl;
  const _EmergencyCard({required this.e, required this.ctrl});

  Color _priorityColor(String p) {
    switch (p) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'TRIGGERED':
        return Colors.red;
      case 'DISPATCHED':
        return Colors.orange;
      case 'EN_ROUTE':
        return Colors.blue;
      case 'ARRIVED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _priorityColor(e.priority).withValues(alpha: 0.4),
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _priorityColor(e.priority).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emergency,
                    color: _priorityColor(e.priority), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.description ?? 'Emergency Alert',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                  ),
                ),
                _PriorityBadge(priority: e.priority),
              ],
            ),
            const SizedBox(height: 8),
            if (e.address != null)
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(e.address!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(e.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(e.status,
                      style: TextStyle(
                          fontSize: 11,
                          color: _statusColor(e.status),
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  e.createdAt.length > 10
                      ? e.createdAt.substring(0, 16).replaceAll('T', '  ')
                      : e.createdAt,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatusProgressRow(current: e.status, ctrl: ctrl, emergencyId: e.id),
          ],
        ),
      ),
    );
  }
}

class _StatusProgressRow extends StatelessWidget {
  final String current;
  final String emergencyId;
  final AdminController ctrl;

  const _StatusProgressRow(
      {required this.current,
      required this.emergencyId,
      required this.ctrl});

  static const _flow = [
    'TRIGGERED',
    'DISPATCHED',
    'EN_ROUTE',
    'ARRIVED',
    'RESOLVED'
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _flow.indexOf(current);
    if (currentIdx == _flow.length - 1) {
      return const SizedBox.shrink();
    }
    final nextStatus = _flow[currentIdx + 1];
    return ElevatedButton.icon(
      onPressed: () => ctrl.updateEmergencyStatus(emergencyId, nextStatus),
      icon: const Icon(Icons.arrow_forward, size: 16),
      label: Text('Mark as $nextStatus'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        minimumSize: const Size(double.infinity, 40),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  Color get color {
    switch (priority) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(priority,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    );
  }
}
