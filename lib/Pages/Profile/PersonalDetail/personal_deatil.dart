// import 'package:flutter/material.dart';
// // Assuming this is your config path
// import 'package:home_care/Config/images_config.dart';

// class PersonalDetailsPage extends StatelessWidget {
//   const PersonalDetailsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // 1. Gradient Background
//           Container(
//             height: MediaQuery.of(context).size.height * 0.4,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF8E54E9),
//                   Color(0xFFF06292),
//                   Color(0xFFF57C00),
//                 ],
//               ),
//             ),
//           ),

//           // 2. Main Content
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildHeader(context),

//                   // The White Detail Card
//                   Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.only(top: 20),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 10,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(40),
//                         topRight: Radius.circular(40),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 10),

//                         // --- SECTION 1: BASIC INFORMATION (Expandable) ---
//                         _buildExpandableSection(
//                           icon: Icons.person,
//                           title: "BASIC INFORMATION",
//                           initiallyExpanded: true,
//                           children: [
//                             _buildInfoTile("Full Name", "Alex Morgan"),
//                             _buildInfoTile(
//                               "Email Address",
//                               "alex.morgan@healthmail.com",
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildInfoTile(
//                                     "Phone Number",
//                                     "+91 987 65 43210",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 15),
//                                 Expanded(
//                                   child: _buildInfoTile("Gender", "Male"),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 10),
//                         const Divider(height: 1, color: Color(0xFFEEEEEE)),
//                         const SizedBox(height: 20),

//                         // --- SECTION 2: STATUS OVERVIEW ---
//                         _SectionHeader(
//                           icon: Icons.verified,
//                           title: "STATUS OVERVIEW",
//                         ),
//                         const SizedBox(height: 15),
//                         _buildStatusRow(),

//                         const SizedBox(height: 20),
//                         const Divider(height: 1, color: Color(0xFFEEEEEE)),

//                         // --- SECTION 3: ADDRESS (Expandable) ---
//                         _buildExpandableSection(
//                           icon: Icons.home,
//                           title: "PRIMARY ADDRESS",
//                           children: [_buildAddressDetails()],
//                         ),

//                         const SizedBox(height: 30),
//                         _buildFamilyButton(),
//                         const SizedBox(height: 20),
//                         const Center(
//                           child: Text(
//                             "Last updated on Oct 24, 2023",
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- UI COMPONENTS ---

//   Widget _buildHeader(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Row(
//             children: [
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//               ),
//               const Expanded(
//                 child: Center(
//                   child: Text(
//                     "Personal Details",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 48),
//             ],
//           ),
//         ),
//         const CircleAvatar(
//           radius: 55,
//           backgroundColor: Colors.white24,
//           child: CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.grey,
//             child: Icon(Icons.person, size: 50, color: Colors.white),
//             // backgroundImage: AssetImage(AssetsImage.profileImage),
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           "Alex Morgan",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Text(
//           "Patient ID: #883920",
//           style: TextStyle(color: Colors.white70, fontSize: 14),
//         ),
//       ],
//     );
//   }

//   Widget _buildExpandableSection({
//     required IconData icon,
//     required String title,
//     required List<Widget> children,
//     bool initiallyExpanded = false,
//   }) {
//     return Theme(
//       data: ThemeData().copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         initiallyExpanded: initiallyExpanded,
//         tilePadding: EdgeInsets.zero,
//         leading: Icon(icon, size: 20, color: const Color(0xFF8E54E9)),
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: Color(0xFF8E54E9),
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             letterSpacing: 0.5,
//           ),
//         ),
//         children: children,
//       ),
//     );
//   }

//   Widget _buildInfoTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),
//           const SizedBox(height: 8),
//           Divider(color: Colors.grey[200], thickness: 1),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusRow() {
//     return Row(
//       children: const [
//         Expanded(
//           child: _StatusCard(
//             label: "User Status",
//             value: "Active",
//             isGold: false,
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: _StatusCard(
//             label: "Service Status",
//             value: "Gold Member",
//             isGold: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddressDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: _buildInfoTile("HOUSE NO.", "123")),
//             const SizedBox(width: 20),
//             Expanded(child: _buildInfoTile("PIN CODE", "226021")),
//           ],
//         ),
//         _buildInfoTile("STREET", "Jankipuram, Sector-H"),
//         _buildInfoTile("LANDMARK", "Near City Park"),
//         const SizedBox(height: 10),
//         const Text(
//           "GEO LOCATION",
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             _buildCoordChip("↑ 26.8467°"),
//             const SizedBox(width: 10),
//             _buildCoordChip("→ 80.9462°"),
//           ],
//         ),
//         const SizedBox(height: 25),
//         _SectionHeader(
//           icon: Icons.location_on,
//           title: "SECONDARY ADDRESS",
//           color: Colors.grey,
//         ),
//         const SizedBox(height: 15),
//         _buildSecondaryAddressPlaceholder(),
//       ],
//     );
//   }

//   Widget _buildCoordChip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3E5F5),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Color(0xFF8E54E9),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSecondaryAddressPlaceholder() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: const Center(
//         child: Text(
//           "No secondary address available",
//           style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
//         ),
//       ),
//     );
//   }

//   Widget _buildFamilyButton() {
//     return Container(
//       width: double.infinity,
//       height: 55,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF8E54E9).withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//         onPressed: () {},
//         icon: const Icon(Icons.people, color: Colors.white),
//         label: const Text(
//           "View Family Report",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Color? color;
//   const _SectionHeader({required this.icon, required this.title, this.color});

//   @override
//   Widget build(BuildContext context) {
//     final themeColor = color ?? const Color(0xFF8E54E9);
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: themeColor),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             color: themeColor,
//             fontWeight: FontWeight.bold,
//             fontSize: 13,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StatusCard extends StatelessWidget {
//   final String label, value;
//   final bool isGold;
//   const _StatusCard({
//     required this.label,
//     required this.value,
//     required this.isGold,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isGold ? const Color(0xFFFFF8E1) : const Color(0xFFF1F8E9),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 isGold ? Icons.stars : Icons.check_circle,
//                 size: 16,
//                 color: isGold ? Colors.orange : Colors.green,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isGold ? Colors.orange[800] : Colors.green[800],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/Widget/address_chip.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/Widget/info_card.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/Widget/section_title.dart';
import 'package:home_care/Pages/Profile/PersonalDetail/Widget/status_card.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E54E9),
                  Color(0xFFF06292),
                  Color(0xFFF57C00),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),

                  // White Detail Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // --- Basic Info Section ---
                        _buildExpandableSection(
                          icon: Icons.person,
                          title: "BASIC INFORMATION",
                          initiallyExpanded: true,
                          children: [
                            InfoCard(label: "Full Name", value: "Alex Morgan"),
                            InfoCard(
                              label: "Email Address",
                              value: "alex.morgan@healthmail.com",
                            ),
                            Row(
                              children: const [
                                Expanded(
                                  child: InfoCard(
                                    label: "Phone Number",
                                    value: "+91 987 65 43210",
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: InfoCard(
                                    label: "Gender",
                                    value: "Male",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),

                        // --- Status Overview ---
                        const SectionTitle(
                          icon: Icons.verified,
                          title: "STATUS OVERVIEW",
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Expanded(
                              child: StatusCard(
                                label: "User Status",
                                value: "Active",
                                isGold: false,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: StatusCard(
                                label: "Service Status",
                                value: "Gold Member",
                                isGold: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),

                        // --- Primary Address ---
                        _buildExpandableSection(
                          icon: Icons.home,
                          title: "PRIMARY ADDRESS",
                          children: [_buildAddressDetails()],
                        ),

                        const SizedBox(height: 30),
                        _buildFamilyButton(),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "Last updated on Oct 24, 2023",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.offAllNamed("/profile"),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Personal Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white24,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Alex Morgan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Patient ID: #883920",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        leading: Icon(icon, size: 20, color: const Color(0xFF8E54E9)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E54E9),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: InfoCard(label: "HOUSE NO.", value: "123"),
            ),
            SizedBox(width: 20),
            Expanded(
              child: InfoCard(label: "PIN CODE", value: "226021"),
            ),
          ],
        ),
        const InfoCard(label: "STREET", value: "Jankipuram, Sector-H"),
        const InfoCard(label: "LANDMARK", value: "Near City Park"),
        const SizedBox(height: 10),
        const Text(
          "GEO LOCATION",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            AddressChip(text: "↑ 26.8467°"),
            SizedBox(width: 10),
            AddressChip(text: "→ 80.9462°"),
          ],
        ),
        const SizedBox(height: 25),
        const SectionTitle(
          icon: Icons.location_on,
          title: "SECONDARY ADDRESS",
          color: Colors.grey,
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey),
          ),
          child: const Center(
            child: Text(
              "No secondary address available",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E54E9).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => Get.offAndToNamed('/faimly-report'),
        icon: const Icon(Icons.people, color: Colors.white),
        label: const Text(
          "View Family Report",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
