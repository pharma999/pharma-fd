import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/admin_model.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  final ctrl = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Support Tickets',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF7B1FA2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: ['', 'OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s.isEmpty ? 'All' : s),
                                selected:
                                    ctrl.ticketStatusFilter.value == s,
                                onSelected: (_) {
                                  ctrl.ticketStatusFilter.value = s;
                                  ctrl.fetchTickets(
                                      status: s.isEmpty ? null : s);
                                },
                                selectedColor: const Color(0xFF7B1FA2)
                                    .withValues(alpha: 0.15),
                              ),
                            ))
                        .toList(),
                  )),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoadingTickets.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.tickets.isEmpty) {
                return const Center(child: Text('No tickets found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.tickets.length,
                itemBuilder: (_, i) =>
                    _TicketTile(ticket: ctrl.tickets[i], ctrl: ctrl),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final SupportTicket ticket;
  final AdminController ctrl;
  const _TicketTile({required this.ticket, required this.ctrl});

  Color _priorityColor(String p) {
    switch (p) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ticket.subject,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _priorityColor(ticket.priority)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(ticket.priority,
                      style: TextStyle(
                          fontSize: 10,
                          color: _priorityColor(ticket.priority),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('From: ${ticket.userName} • ${ticket.userPhone}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text('Category: ${ticket.category}',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Text(ticket.description,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatusChip(status: ticket.status),
                const Spacer(),
                if (ticket.isOpen)
                  TextButton(
                    onPressed: () =>
                        _showResolveDialog(context, ticket, ctrl),
                    child: const Text('Resolve',
                        style: TextStyle(color: Color(0xFF7B1FA2))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(
      BuildContext ctx, SupportTicket t, AdminController ctrl) {
    final resCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Resolve Ticket'),
        content: TextField(
          controller: resCtrl,
          decoration: const InputDecoration(
              hintText: 'Enter resolution note...', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ctrl.resolveTicket(t.id, resolution: resCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get color {
    switch (status) {
      case 'OPEN':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
