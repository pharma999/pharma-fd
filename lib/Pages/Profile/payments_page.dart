import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  int selectedTab = 0; // 0: All, 1: Paid, 2: Pending

  final List<Payment> allPayments = [
    Payment(
      service: 'Doctor Consultation',
      doctor: 'Dr. Sarah Johnson',
      amount: '₹500',
      date: '10 Apr 2026',
      time: '2:00 PM',
      status: 'Paid',
      method: 'Card',
    ),
    Payment(
      service: 'Lab Test',
      doctor: 'Central Labs',
      amount: '₹1,200',
      date: '08 Apr 2026',
      time: '10:30 AM',
      status: 'Paid',
      method: 'UPI',
    ),
    Payment(
      service: 'Pharmacy Purchase',
      doctor: 'MediCare Pharmacy',
      amount: '₹850',
      date: '05 Apr 2026',
      time: '3:15 PM',
      status: 'Pending',
      method: 'Wallet',
    ),
    Payment(
      service: 'Physiotherapy Session',
      doctor: 'Dr. Mike Chen',
      amount: '₹600',
      date: '02 Apr 2026',
      time: '11:00 AM',
      status: 'Paid',
      method: 'Bank Transfer',
    ),
    Payment(
      service: 'Home Nurse Visit',
      doctor: 'HealthCare Plus',
      amount: '₹1,500',
      date: '01 Apr 2026',
      time: '9:00 AM',
      status: 'Pending',
      method: 'Credit Card',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPayments = selectedTab == 0
        ? allPayments
        : selectedTab == 1
        ? allPayments.where((p) => p.status == 'Paid').toList()
        : allPayments.where((p) => p.status == 'Pending').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: const Text(
          'Payments',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6BC4FF), Color(0xFFE3F2FD)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),

          // Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('All', 0),
                  const SizedBox(width: 8),
                  _buildTab('Paid', 1),
                  const SizedBox(width: 8),
                  _buildTab('Pending', 2),
                ],
              ),
            ),
          ),

          // Payments List
          Expanded(
            child: filteredPayments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(filteredPayments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalAmount = allPayments
        .fold<double>(0, (sum, payment) {
          final amount = int.parse(
            payment.amount.replaceAll(RegExp(r'[^\d]'), ''),
          );
          return sum + amount;
        })
        .toStringAsFixed(0);

    final paidAmount = allPayments
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (sum, payment) {
          final amount = int.parse(
            payment.amount.replaceAll(RegExp(r'[^\d]'), ''),
          );
          return sum + amount;
        })
        .toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spending',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₹$totalAmount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paid',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹$paidAmount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(int.parse(totalAmount) - int.parse(paidAmount))}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final statusColor = payment.status == 'Paid' ? Colors.green : Colors.orange;
    final statusIcon = payment.status == 'Paid'
        ? Icons.check_circle
        : Icons.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.receipt, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.service,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      payment.doctor,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BCD4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        payment.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date & Time',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${payment.date} at ${payment.time}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payment.method,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Payment {
  final String service;
  final String doctor;
  final String amount;
  final String date;
  final String time;
  final String status;
  final String method;

  Payment({
    required this.service,
    required this.doctor,
    required this.amount,
    required this.date,
    required this.time,
    required this.status,
    required this.method,
  });
}
