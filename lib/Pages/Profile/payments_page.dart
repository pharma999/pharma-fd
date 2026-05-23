import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/payment_controller.dart';
import 'package:home_care/Model/payment_model.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PaymentController());
    return _PaymentsView(ctrl: ctrl);
  }
}

class _PaymentsView extends StatefulWidget {
  final PaymentController ctrl;
  const _PaymentsView({required this.ctrl});

  @override
  State<_PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<_PaymentsView> {
  int _tab = 0; // 0: All, 1: Paid, 2: Pending

  static const _cyan = Color(0xFF0097A7);

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
              colors: [Color(0xFF0097A7), Color(0xFF6BC4FF)],
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
        title: const Text('Payments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: widget.ctrl.fetchHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (widget.ctrl.isLoading.value && widget.ctrl.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _cyan));
        }
        if (widget.ctrl.error.value.isNotEmpty && widget.ctrl.payments.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(widget.ctrl.error.value, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.ctrl.fetchHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ]),
          );
        }
        final list = _tab == 0
            ? widget.ctrl.payments
            : _tab == 1
                ? widget.ctrl.paid.obs
                : widget.ctrl.pending.obs;

        return Column(
          children: [
            _SummaryCard(ctrl: widget.ctrl),
            _TabRow(selected: _tab, onTap: (i) => setState(() => _tab = i)),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No payments found',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                      ]),
                    )
                  : RefreshIndicator(
                      color: _cyan,
                      onRefresh: widget.ctrl.fetchHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _PaymentCard(payment: list[i]),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final PaymentController ctrl;
  const _SummaryCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0097A7), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF0097A7).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Spending', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('₹${ctrl.totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _SumCell(label: 'Paid', amount: ctrl.totalSpent, color: Colors.greenAccent.shade400)),
            Container(width: 1, height: 36, color: Colors.white24),
            Expanded(child: _SumCell(label: 'Pending', amount: ctrl.totalPending, color: Colors.orangeAccent.shade200)),
            Container(width: 1, height: 36, color: Colors.white24),
            Expanded(child: _SumCell(label: 'Transactions', amount: ctrl.payments.length.toDouble(), color: Colors.lightBlueAccent, isCount: true)),
          ]),
        ],
      ),
    ));
  }
}

class _SumCell extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isCount;
  const _SumCell({required this.label, required this.amount, required this.color, this.isCount = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(isCount ? amount.toInt().toString() : '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
    ]);
  }
}

// ── Tab row ────────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _TabRow({required this.selected, required this.onTap});

  static const _labels = ['All', 'Paid', 'Pending'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final isSel = selected == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF0097A7) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Text(_labels[i],
                  style: TextStyle(
                    color: isSel ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          );
        }),
      ),
    );
  }
}

// ── Payment card ───────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentCard({required this.payment});

  static const _statusColors = <String, Color>{
    'COMPLETED': Color(0xFF10B981),
    'PENDING': Color(0xFFF59E0B),
    'FAILED': Color(0xFFEF4444),
    'REFUNDED': Color(0xFF8B5CF6),
  };

  static const _methodIcons = <String, IconData>{
    'WALLET': Icons.account_balance_wallet_outlined,
    'CARD': Icons.credit_card,
    'UPI': Icons.qr_code,
    'BANK_TRANSFER': Icons.account_balance_outlined,
    'CASH': Icons.money,
  };

  String get _formattedDate {
    final raw = payment.paidAt ?? payment.createdAt;
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day} ${_mon(dt.month)} ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  String _mon(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[payment.status] ?? Colors.grey;
    final methodIcon = _methodIcons[payment.paymentMethod.toUpperCase()] ?? Icons.payment;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.bookingId != null ? 'Booking Payment' :
                        payment.appointmentId != null ? 'Appointment Fee' : 'Payment',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(_formattedDate,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0097A7))),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(payment.status,
                        style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              Icon(methodIcon, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(payment.paymentMethod.replaceAll('_', ' '),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const Spacer(),
              if (payment.transactionId != null && payment.transactionId!.isNotEmpty) ...[
                Icon(Icons.tag, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  payment.transactionId!.length > 12
                      ? '${payment.transactionId!.substring(0, 12)}…'
                      : payment.transactionId!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}
