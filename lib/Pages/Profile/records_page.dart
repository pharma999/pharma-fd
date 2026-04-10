import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final List<MedicalRecord> records = [
    MedicalRecord(
      title: 'Blood Report',
      date: '10 Apr 2026',
      doctor: 'Dr. Sarah Johnson',
      status: 'Ready',
      icon: Icons.bloodtype,
      color: Colors.red,
    ),
    MedicalRecord(
      title: 'X-Ray Report',
      date: '08 Apr 2026',
      doctor: 'Dr. Mike Chen',
      status: 'Processing',
      icon: Icons.image_search,
      color: Colors.blue,
    ),
    MedicalRecord(
      title: 'Prescription',
      date: '05 Apr 2026',
      doctor: 'Dr. Emily Brown',
      status: 'Ready',
      icon: Icons.description,
      color: Colors.green,
    ),
    MedicalRecord(
      title: 'Lab Test Results',
      date: '02 Apr 2026',
      doctor: 'Dr. Robert Wilson',
      status: 'Ready',
      icon: Icons.science,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Medical Records',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          return _buildRecordCard(records[index]);
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final statusColor = record.status == 'Ready' ? Colors.green : Colors.orange;

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
                  color: record.color.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Icon(record.icon, color: record.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      record.doctor,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.date,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Color(0xFF00BCD4),
                      size: 20,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Color(0xFF00BCD4),
                      size: 20,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF00BCD4),
                      size: 20,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
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

class MedicalRecord {
  final String title;
  final String date;
  final String doctor;
  final String status;
  final IconData icon;
  final Color color;

  MedicalRecord({
    required this.title,
    required this.date,
    required this.doctor,
    required this.status,
    required this.icon,
    required this.color,
  });
}
