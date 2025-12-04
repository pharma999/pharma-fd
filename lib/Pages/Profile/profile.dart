import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    const name = "Adarsh";
    const URL = "assets/images/profile.jpg";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF), // SAME as before

      appBar: AppBar(
        backgroundColor: const Color(0xFF6750A4), // SAME purple theme
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.offAllNamed("/homePage"),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Health Profile'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // PROFILE HEADER
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage(URL),
              onBackgroundImageError: (_, __) {},
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // ⭐ NAME + PATIENT ID + EDIT BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Adarsh Verma',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Patient ID: #AV10245',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: () {
                    // Add navigation or edit action here
                  },
                  icon: const Icon(Icons.edit, color: Color(0xFF6750A4)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CONTACT INFO
            _buildCard(
              title: 'Personal Information',
              children: const [
                ListTile(
                  leading: Icon(Icons.email, color: Color(0xFF6750A4)),
                  title: Text('adarshv978@gmail.com'),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xFF6750A4)),
                  title: Text('+91 6386098744'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on, color: Color(0xFF6750A4)),
                  title: Text('Lucknow, India'),
                ),
              ],
            ),

            // MY REPORTS
            _buildCard(
              title: 'My Health Reports',
              children: [
                _reportTile("Blood Test Report", "12 Feb 2025"),
                _reportTile("X-ray Chest", "05 Jan 2025"),
                _reportTile("General Checkup", "28 Dec 2024"),
                const SizedBox(height: 10),
                _primaryButton("View All Reports"),
              ],
            ),

            // FAMILY REPORTS
            _buildCard(
              title: 'Family Member Reports',
              children: [
                _familyTile("Ravi Verma", "Diabetes Test - Jan 2025"),
                _familyTile("Sita Verma", "Eye Checkup - Dec 2024"),
                const SizedBox(height: 10),
                _primaryButton("View Family Records"),
              ],
            ),

            // APPOINTMENT HISTORY
            _buildCard(
              title: 'Appointment History',
              children: [
                _appointmentTile(
                  "Dr. Anita Sharma",
                  "Cardiologist",
                  "22 Feb 2025",
                  "10:00 AM",
                ),
                _appointmentTile(
                  "Dr. Rakesh Singh",
                  "Physician",
                  "10 Jan 2025",
                  "04:30 PM",
                ),
                const SizedBox(height: 10),
                _primaryButton("View All Appointments"),
              ],
            ),

            // BOOK DOCTOR
            _buildCard(
              title: 'Book New Appointment',
              children: [
                _doctorCard(
                  "Dr. Priya Mehta",
                  "Dermatologist",
                  "City Hospital, Lucknow",
                  "Slots: 4PM - 8PM",
                ),
                const SizedBox(height: 12),
                _primaryButton("See All Doctors"),
              ],
            ),

            const SizedBox(height: 30),

            // EDIT PROFILE BUTTON
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMMON CARD
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4), // SAME PURPLE TITLE
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // REPORT TILE
  Widget _reportTile(String report, String date) {
    return ListTile(
      leading: const Icon(Icons.description, color: Color(0xFF6750A4)),
      title: Text(report),
      subtitle: Text(date),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
    );
  }

  // FAMILY REPORT TILE
  Widget _familyTile(String name, String report) {
    return ListTile(
      leading: const Icon(Icons.family_restroom, color: Color(0xFF6750A4)),
      title: Text(name),
      subtitle: Text(report),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
    );
  }

  // APPOINTMENT TILE
  Widget _appointmentTile(
    String doctor,
    String specialist,
    String date,
    String time,
  ) {
    return ListTile(
      leading: const Icon(Icons.history, color: Color(0xFF6750A4)),
      title: Text(doctor),
      subtitle: Text("$specialist\n$date  •  $time"),
      isThreeLine: true,
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
    );
  }

  // DOCTOR CARD
  Widget _doctorCard(String name, String type, String location, String slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6750A4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Color(0xFF6750A4), size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(type),
                Text(location, style: TextStyle(color: Colors.grey.shade700)),
                Text(slot, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
            ),
            child: const Text("Book", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // COMMON PURPLE BUTTON
  Widget _primaryButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
