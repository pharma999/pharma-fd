import 'package:flutter/material.dart';

void showAppointments(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "My Appointments",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _appointmentTile(
              doctor: "Dr. Anjali Gupta",
              service: "Physiotherapy",
              date: "12 Oct 2025",
              time: "10:30 AM",
              status: "Completed",
              statusColor: Colors.green,
            ),
            _appointmentTile(
              doctor: "Dr. Rahul Sharma",
              service: "Cardiology",
              date: "20 Oct 2025",
              time: "02:00 PM",
              status: "Upcoming",
              statusColor: Colors.orange,
            ),
            _appointmentTile(
              doctor: "Dr. Neha Verma",
              service: "Pediatric Care",
              date: "25 Oct 2025",
              time: "11:00 AM",
              status: "Cancelled",
              statusColor: Colors.red,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 2,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    },
  );
}

Widget _appointmentTile({
  required String doctor,
  required String service,
  required String date,
  required String time,
  required String status,
  required Color statusColor,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      leading: const Icon(Icons.person, color: Colors.blue),
      title: Text(doctor, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("$service\n$date • $time"),
      isThreeLine: true,
      trailing: Text(
        status,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
