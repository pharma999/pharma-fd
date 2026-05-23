import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/support_controller.dart';
import 'package:home_care/Model/support_model.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SupportController());
    return _HelpView(ctrl: ctrl);
  }
}

class _HelpView extends StatefulWidget {
  final SupportController ctrl;
  const _HelpView({required this.ctrl});

  @override
  State<_HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<_HelpView> {
  int _tab = 0;

  static const _cyan = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF6BC4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Help & Support',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: widget.ctrl.fetchTickets,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _cyan,
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Ticket', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Quick help cards
          _QuickHelp(),
          const SizedBox(height: 4),
          // Ticket tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Text('My Tickets',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
              const Spacer(),
              _SmallTab(label: 'Open', index: 0, selected: _tab, onTap: (i) => setState(() => _tab = i)),
              const SizedBox(width: 8),
              _SmallTab(label: 'Resolved', index: 1, selected: _tab, onTap: (i) => setState(() => _tab = i)),
            ]),
          ),
          Expanded(
            child: Obx(() {
              if (widget.ctrl.isLoading.value && widget.ctrl.tickets.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: _cyan));
              }
              if (widget.ctrl.error.value.isNotEmpty && widget.ctrl.tickets.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(widget.ctrl.error.value, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: widget.ctrl.fetchTickets,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ]),
                );
              }
              final list = _tab == 0 ? widget.ctrl.open : widget.ctrl.resolved;
              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.support_agent_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(_tab == 0 ? 'No open tickets' : 'No resolved tickets',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    if (_tab == 0)
                      TextButton.icon(
                        onPressed: () => _showCreateSheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create a ticket'),
                      ),
                  ]),
                );
              }
              return RefreshIndicator(
                color: _cyan,
                onRefresh: widget.ctrl.fetchTickets,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _TicketCard(ticket: list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateTicketSheet(ctrl: widget.ctrl),
    );
  }
}

// ── Quick help ─────────────────────────────────────────────────────────────────

class _QuickHelp extends StatelessWidget {
  final _items = const [
    (Icons.phone_outlined, 'Call Us', '1800-XXX-XXXX'),
    (Icons.email_outlined, 'Email Us', 'support@homecare.in'),
    (Icons.chat_bubble_outline, 'Live Chat', 'Chat now'),
    (Icons.quiz_outlined, 'FAQs', 'Browse FAQs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items.map((item) => _QuickCard(item.$1, item.$2, item.$3)).toList(),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _QuickCard(this.icon, this.label, this.sub);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF06B6D4), size: 22),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
    ]);
  }
}

// ── Small tab ──────────────────────────────────────────────────────────────────

class _SmallTab extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  const _SmallTab({required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = selected == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF06B6D4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSel ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            )),
      ),
    );
  }
}

// ── Ticket card ────────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketCard({required this.ticket});

  static const _statusColors = <String, Color>{
    'OPEN': Color(0xFF3B82F6),
    'IN_REVIEW': Color(0xFFF59E0B),
    'RESOLVED': Color(0xFF10B981),
    'CLOSED': Color(0xFF6B7280),
  };

  static const _priorityColors = <String, Color>{
    'LOW': Color(0xFF10B981),
    'MEDIUM': Color(0xFF3B82F6),
    'HIGH': Color(0xFFF59E0B),
    'URGENT': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[ticket.status] ?? Colors.grey;
    final priorityColor = _priorityColors[ticket.priority] ?? Colors.grey;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(ticket.subject,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(ticket.status.replaceAll('_', ' '),
                      style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(ticket.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(ticket.category,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(ticket.priority,
                      style: TextStyle(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ]),
              if (ticket.resolution != null && ticket.resolution!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(ticket.resolution!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TicketDetailSheet(ticket: ticket),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }
}

// ── Ticket detail sheet ────────────────────────────────────────────────────────

class _TicketDetailSheet extends StatelessWidget {
  final SupportTicket ticket;
  const _TicketDetailSheet({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(ticket.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(ticket.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
          const SizedBox(height: 16),
          _Row('Category', ticket.category),
          _Row('Priority', ticket.priority),
          _Row('Status', ticket.status.replaceAll('_', ' ')),
          if (ticket.referenceId != null && ticket.referenceId!.isNotEmpty)
            _Row('Reference', ticket.referenceId!),
          _Row('Created', ticket.createdAt.length > 10 ? ticket.createdAt.substring(0, 10) : ticket.createdAt),
          if (ticket.resolution != null && ticket.resolution!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Resolution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(ticket.resolution!, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Create ticket sheet ────────────────────────────────────────────────────────

class _CreateTicketSheet extends StatefulWidget {
  final SupportController ctrl;
  const _CreateTicketSheet({required this.ctrl});

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'GENERAL';
  String _priority = 'MEDIUM';

  static const _categories = ['GENERAL', 'BILLING', 'BOOKING', 'TECHNICAL', 'MEDICAL', 'OTHER'];
  static const _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];
  static const _cyan = Color(0xFF06B6D4);

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Subject is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Description is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Navigator.pop(context);
    final ok = await widget.ctrl.createTicket(
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      priority: _priority,
    );
    if (ok) {
      Get.snackbar('Ticket Created', 'We will get back to you soon',
          backgroundColor: Colors.green.shade50, colorText: Colors.green.shade700,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error',
          widget.ctrl.error.value.isNotEmpty ? widget.ctrl.error.value : 'Failed to create ticket',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('New Support Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 14),

            // Category chips
            const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _categories.map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? _cyan : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c,
                        style: TextStyle(
                          fontSize: 12,
                          color: sel ? Colors.white : Colors.grey.shade700,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Priority chips
            const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _priorities.map((p) {
                final sel = _priority == p;
                const colors = {'LOW': Color(0xFF10B981), 'MEDIUM': Color(0xFF3B82F6), 'HIGH': Color(0xFFF59E0B), 'URGENT': Color(0xFFEF4444)};
                final col = colors[p] ?? Colors.grey;
                return GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? col : col.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p,
                        style: TextStyle(
                          fontSize: 12,
                          color: sel ? Colors.white : col,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            _SheetField('Subject *', _subjectCtrl),
            const SizedBox(height: 10),
            _SheetField('Description *', _descCtrl, maxLines: 4),
            const SizedBox(height: 20),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: widget.ctrl.isCreating.value ? null : _submit,
                child: widget.ctrl.isCreating.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  final int maxLines;
  const _SheetField(this.hint, this.ctrl, {this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
