import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
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
  int _tab = 0; // 0: All  1: Paid  2: Pending

  static const _labels = ['All', 'Paid', 'Pending'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kPrimary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kSurface, size: 20),
        ),
        title: const Text('Payments & Wallet',
            style: TextStyle(
                color: kSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kSurface),
            onPressed: widget.ctrl.fetchHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (widget.ctrl.isLoading.value && widget.ctrl.payments.isEmpty) {
          return _buildSkeleton();
        }
        if (widget.ctrl.error.value.isNotEmpty &&
            widget.ctrl.payments.isEmpty) {
          return _ErrorState(
              message: widget.ctrl.error.value,
              onRetry: widget.ctrl.fetchHistory);
        }

        final list = _tab == 0
            ? widget.ctrl.payments
            : _tab == 1
                ? widget.ctrl.paid.obs
                : widget.ctrl.pending.obs;

        return Column(children: [
          // ── Wallet header ──────────────────────────────────────────────
          _WalletHeader(ctrl: widget.ctrl),

          // ── Filter chips ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(_labels.length, (i) {
                final sel = _tab == i;
                return GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? kPrimary : kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? kPrimary : kBorder,
                          width: sel ? 1.5 : 1),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                    child: Text(_labels[i],
                        style: TextStyle(
                            color: sel ? kSurface : kTextMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                );
              }),
            ),
          ),

          // ── Transactions list ──────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? _EmptyState()
                : RefreshIndicator(
                    color: kPrimary,
                    onRefresh: widget.ctrl.fetchHistory,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) =>
                          _PaymentCard(payment: list[i]),
                    ),
                  ),
          ),
        ]);
      }),
    );
  }

  Widget _buildSkeleton() {
    return Column(children: [
      // Wallet card skeleton
      Container(
        margin: const EdgeInsets.all(16),
        height: 140,
        decoration: BoxDecoration(
          gradient: kPrimaryGradientV,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 80,
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ── Wallet header ─────────────────────────────────────────────────────────────

class _WalletHeader extends StatelessWidget {
  final PaymentController ctrl;
  const _WalletHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: kPrimaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: kPrimary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: kSurface.withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                  child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: kSurface,
                      size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Total Spending',
                    style: TextStyle(
                        color: kSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 10),
              Text(
                '₹${ctrl.totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: kSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: kSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 14),
              Row(children: [
                _WalletStat('Paid',
                    '₹${ctrl.totalSpent.toStringAsFixed(0)}',
                    kAccent),
                Container(
                    width: 1,
                    height: 32,
                    color: kSurface.withValues(alpha: 0.2)),
                _WalletStat('Pending',
                    '₹${ctrl.totalPending.toStringAsFixed(0)}',
                    kWarning),
                Container(
                    width: 1,
                    height: 32,
                    color: kSurface.withValues(alpha: 0.2)),
                _WalletStat(
                    'Transactions',
                    '${ctrl.payments.length}',
                    kPrimaryLight),
              ]),
            ],
          ),
        ));
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _WalletStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                color: kSurface.withValues(alpha: 0.7),
                fontSize: 10)),
      ]),
    );
  }
}

// ── Payment card ──────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentCard({required this.payment});

  // All from colors_coning.dart
  static const _statusColors = <String, Color>{
    'COMPLETED': kSuccess,
    'PENDING':   kWarning,
    'FAILED':    kError,
    'REFUNDED':  kPurple,
  };

  static const _methodIcons = <String, IconData>{
    'WALLET':        Icons.account_balance_wallet_outlined,
    'CARD':          Icons.credit_card_rounded,
    'UPI':           Icons.qr_code_rounded,
    'BANK_TRANSFER': Icons.account_balance_outlined,
    'CASH':          Icons.money_rounded,
  };

  String get _formattedDate {
    final raw = payment.paidAt ?? payment.createdAt;
    try {
      final dt = DateTime.parse(raw).toLocal();
      const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${m[dt.month]} ${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColors[payment.status] ?? kTextMedium;
    final mi = _methodIcons[payment.paymentMethod.toUpperCase()] ??
        Icons.payment_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: sc.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded,
                  color: sc, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  payment.bookingId != null
                      ? 'Booking Payment'
                      : payment.appointmentId != null
                          ? 'Appointment Fee'
                          : 'Payment',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kTextDark),
                ),
                Text(_formattedDate,
                    style: const TextStyle(
                        fontSize: 11, color: kTextLight)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '₹${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimary),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(payment.status,
                    style: TextStyle(
                        fontSize: 10,
                        color: sc,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: kDivider),
          const SizedBox(height: 10),
          Row(children: [
            Icon(mi, size: 13, color: kTextLight),
            const SizedBox(width: 6),
            Text(payment.paymentMethod.replaceAll('_', ' '),
                style: const TextStyle(
                    fontSize: 12, color: kTextMedium)),
            const Spacer(),
            if ((payment.transactionId ?? '').isNotEmpty) ...[
              const Icon(Icons.tag, size: 12, color: kTextLight),
              const SizedBox(width: 4),
              Text(
                (payment.transactionId!.length > 12
                    ? '${payment.transactionId!.substring(0, 12)}…'
                    : payment.transactionId!),
                style: const TextStyle(
                    fontSize: 11, color: kTextLight),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded,
                size: 44, color: kPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No Transactions Found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text('Your payment history will\nappear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMedium, fontSize: 13)),
        ]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded,
            size: 52, color: kError.withValues(alpha: 0.6)),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: kTextMedium)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary, foregroundColor: kSurface),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      ]),
    );
  }
}
