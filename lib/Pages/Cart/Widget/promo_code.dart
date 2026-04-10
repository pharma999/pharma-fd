import 'package:flutter/material.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({super.key});

  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  final TextEditingController _promoController = TextEditingController();
  String? _appliedPromo;

  // Sample valid promo codes
  final Map<String, int> validPromoCodes = {
    'SAVE10': 10,
    'SAVE20': 20,
    'WELCOME': 15,
    'FLAT30': 30,
  };

  void _showPromoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Promo Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.local_offer_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Valid codes: SAVE10, SAVE20, WELCOME, FLAT30',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String code = _promoController.text.toUpperCase().trim();
              if (validPromoCodes.containsKey(code)) {
                setState(() => _appliedPromo = code);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Promo code "$code" applied! ${validPromoCodes[code]}% discount',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _promoController.clear();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid promo code'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPromoDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _appliedPromo != null ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _appliedPromo != null ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: _appliedPromo != null ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _appliedPromo != null
                    ? 'Promo: $_appliedPromo'
                    : 'Apply Promo Code',
                style: TextStyle(
                  fontWeight: _appliedPromo != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _appliedPromo != null ? Colors.green : Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _appliedPromo != null ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
