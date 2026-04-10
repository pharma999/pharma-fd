import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController(
    text: 'Alex Morgan',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'alex.morgan@email.com',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '+91 9876543210',
  );
  final TextEditingController ageController = TextEditingController(text: '24');
  final TextEditingController bloodController = TextEditingController(
    text: 'B+',
  );
  final TextEditingController weightController = TextEditingController(
    text: '72 kg',
  );
  final TextEditingController heightController = TextEditingController(
    text: '5\'10"',
  );
  final TextEditingController addressController = TextEditingController(
    text: 'Lucknow Jankipuram Sector-H, Uttar Pradesh, India',
  );

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    bloodController.dispose();
    weightController.dispose();
    heightController.dispose();
    addressController.dispose();
    super.dispose();
  }

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
          'Profile Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Color(0xFF00BCD4)),
            ),
          ),
        ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            const SizedBox(height: 24),

            // Personal Information
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 12),
            _buildTextField('Full Name', nameController),
            const SizedBox(height: 12),
            _buildTextField('Email', emailController),
            const SizedBox(height: 12),
            _buildTextField('Phone', phoneController),
            const SizedBox(height: 12),
            _buildTextField('Address', addressController, maxLines: 3),
            const SizedBox(height: 24),

            // Health Information
            _buildSectionTitle('Health Information'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Age', ageController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Blood Type', bloodController)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Weight', weightController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Height', heightController)),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Contact
            _buildSectionTitle('Medical Conditions'),
            const SizedBox(height: 12),
            _buildConditionChip('Allergies'),
            const SizedBox(height: 8),
            _buildConditionChip('Diabetes'),
            const SizedBox(height: 8),
            _buildConditionChip('Hypertension'),
            const SizedBox(height: 24),

            // Save Button
            if (isEditing)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() => isEditing = false);
                  Get.snackbar('Success', 'Profile updated successfully!');
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00BCD4), width: 4),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isEditing)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00BCD4),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: isEditing,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: isEditing ? Colors.white : Colors.grey.shade100,
      ),
      style: TextStyle(
        color: isEditing ? Colors.black87 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4), width: 1.5),
      ),
      child: Text(
        condition,
        style: const TextStyle(
          color: Color(0xFF00BCD4),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
