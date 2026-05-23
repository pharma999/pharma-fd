import 'package:flutter/material.dart';
import 'package:home_care/Api/Services/wallet_repository.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _repo = WalletRepository();

  double _balance = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final balRes = await _repo.getBalance();
    final txnRes = await _repo.getTransactions();
    balRes.when(
      onSuccess: (d) => setState(() => _balance = (d['balance'] ?? 0).toDouble()),
      onError: (e) => setState(() => _error = e),
    );
    txnRes.when(
      onSuccess: (d) => setState(() => _transactions = d),
      onError: (_) {},
    );
    setState(() => _loading = false);
  }

  Future<void> _showTopUp() async {
    final amounts = [100.0, 200.0, 500.0, 1000.0];
    double selected = 200;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top Up Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: amounts.map((a) => ChoiceChip(
                  label: Text('₹${a.toInt()}'),
                  selected: selected == a,
                  onSelected: (_) => setS(() => selected = a),
                  selectedColor: const Color(0xFF6BC4FF),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BC4FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final res = await _repo.topUp(
                        amount: selected, paymentMethod: 'UPI');
                    res.when(
                      onSuccess: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('₹${selected.toInt()} added!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _load();
                      },
                      onError: (e) => ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e))),
                    );
                  },
                  child: Text('Add ₹${selected.toInt()}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('My Wallet',
            style: TextStyle(color: Color(0xFF312E81), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF312E81),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildBalanceCard(),
                        const SizedBox(height: 8),
                        _buildTransactionsList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6BC4FF), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6BC4FF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Wallet Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${_balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF312E81),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _showTopUp,
              icon: const Icon(Icons.add),
              label: const Text('Add Money',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No transactions yet',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Transaction History',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _transactions.length,
          itemBuilder: (_, i) => _TxnTile(txn: _transactions[i]),
        ),
      ],
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Map<String, dynamic> txn;
  const _TxnTile({required this.txn});

  static const _typeColors = {
    'TOPUP': Colors.green,
    'CREDIT': Colors.green,
    'DEBIT': Colors.red,
    'PAYOUT': Colors.orange,
  };

  static const _typeIcons = {
    'TOPUP': Icons.add_circle_outline,
    'CREDIT': Icons.arrow_downward,
    'DEBIT': Icons.arrow_upward,
    'PAYOUT': Icons.send,
  };

  @override
  Widget build(BuildContext context) {
    final type = txn['type'] as String? ?? 'DEBIT';
    final color = _typeColors[type] ?? Colors.grey;
    final icon = _typeIcons[type] ?? Icons.swap_horiz;
    final isCredit = type == 'TOPUP' || type == 'CREDIT';
    final amount = (txn['amount'] ?? 0).toDouble();
    final balance = (txn['balance'] ?? 0).toDouble();
    final desc = txn['description'] as String? ?? type;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(desc,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text('Balance: ₹${balance.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
