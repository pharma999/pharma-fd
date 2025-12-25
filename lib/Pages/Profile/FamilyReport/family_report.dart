import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class FamilyReportsPage extends StatelessWidget {
  const FamilyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8E54E9), // Fallback for the top
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8E54E9), Color(0xFFF05A22)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopStats(),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          Icons.groups_outlined,
                          "FAMILY MEMBERS",
                        ),
                        const SizedBox(height: 16),
                        _buildMemberCard(
                          name: "Alex Morgan",
                          relation: "Self • 32 Years",
                          status: "Healthy",
                          statusColor: Colors.green.shade50,
                          statusTextColor: Colors.green,
                          footerText: "Last checkup: Oct 24, 2023",
                          actionText: "View Report",
                          image: "https://i.pravatar.cc/150?u=alex",
                        ),
                        _buildMemberCard(
                          name: "David Morgan",
                          relation: "Spouse • 35 Years",
                          status: "Pending Lab",
                          statusColor: Colors.amber.shade50,
                          statusTextColor: Colors.orange,
                          footerText: "Blood Test Results Ready",
                          actionText: "Review",
                          isButton: true,
                          showDot: true,
                          image: "https://i.pravatar.cc/150?u=david",
                        ),
                        _buildMemberCard(
                          name: "Sarah Morgan",
                          relation: "Daughter • 8 Years",
                          status: "Vaccination",
                          statusColor: Colors.blue.shade50,
                          statusTextColor: Colors.blue,
                          footerText: "Next Due: Nov 15, 2023",
                          actionText: "Details",
                          image: "https://i.pravatar.cc/150?u=sarah",
                        ),
                        _buildMemberCard(
                          name: "Robert Smith",
                          relation: "Father • 72 Years",
                          status: "Archived",
                          statusColor: Colors.grey.shade100,
                          statusTextColor: Colors.grey,
                          footerText: "No active reports",
                          actionText: "History",
                          isHistory: true,
                          image: "https://i.pravatar.cc/150?u=robert",
                        ),
                        _buildAddMemberButton(),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          Icons.notifications_none,
                          "LATEST UPDATES",
                        ),
                        const SizedBox(height: 16),
                        _buildUpdateBanner(),
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            "Synced with City Hospital Database • Updated just now",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.offAllNamed("/personal-detail"),
              ),
              const Text(
                "Family Reports",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white24,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=main"),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Alex Morgan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Head of Household",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "FAMILY ID: #FM-883920",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "4",
            "MEMBERS",
            const Color(0xFFF3EFFF),
            const Color(0xFF7B61FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            "2",
            "NEW REPORTS",
            const Color(0xFFFFF7ED),
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String val, String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: textCol,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textCol.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7B61FF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B61FF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String relation,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String footerText,
    required String actionText,
    bool isButton = false,
    bool isHistory = false,
    bool showDot = false,
    required String image,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(image),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          relation,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    footerText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (isButton)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E54E9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          actionText,
                          style: const TextStyle(
                            color: Color(0xFF8E54E9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isHistory ? Icons.history : Icons.chevron_right,
                          size: 18,
                          color: isHistory
                              ? Colors.grey
                              : const Color(0xFF8E54E9),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showDot)
          const Positioned(
            right: 4,
            top: 4,
            child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
          ),
      ],
    );
  }

  Widget _buildAddMemberButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD1C4E9),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Color(0xFF8E54E9)),
          SizedBox(width: 8),
          Text(
            "Add Family Member",
            style: TextStyle(
              color: Color(0xFF8E54E9),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Family Checkup Plan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Your annual family health package expires in 15 days. Renew now to maintain coverage.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
