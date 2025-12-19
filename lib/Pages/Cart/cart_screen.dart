// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   // Quantities for each cart item
//   int qtyPhysiotherapy = 1;
//   int qtyBabyKit = 1;
//   int qtyRehab = 1;

//   @override
//   Widget build(BuildContext context) {
//     double subtotal =
//         45.0 * qtyPhysiotherapy + 28.5 * qtyBabyKit + 60.0 * qtyRehab;
//     double serviceFee = 5.0;
//     double tax = subtotal * 0.05;
//     double total = subtotal + serviceFee + tax;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildAppBar(),
//                   const SizedBox(height: 20),
//                   _buildDeliveryCard(),
//                   const SizedBox(height: 20),
//                   _buildCartItem(
//                     "Physiotherapy Session",
//                     "Dr. Anjali Gupta • 1 Hr",
//                     "\$45.00",
//                     const Color(0xFFE8EAF6),
//                     Icons.spa,
//                     qtyPhysiotherapy,
//                     (val) => setState(() => qtyPhysiotherapy = val),
//                   ),
//                   _buildCartItem(
//                     "Premium Baby Care Kit",
//                     "Includes 5 essentials",
//                     "\$28.50",
//                     const Color(0xFFFFF3E0),
//                     Icons.child_care,
//                     qtyBabyKit,
//                     (val) => setState(() => qtyBabyKit = val),
//                   ),
//                   _buildCartItem(
//                     "Rehabilitation Consult",
//                     "Video Consultation",
//                     "\$60.00",
//                     const Color(0xFFE8F5E9),
//                     Icons.medical_services,
//                     qtyRehab,
//                     (val) => setState(() => qtyRehab = val),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20),
//                     child: Text(
//                       "OFTEN BOOKED TOGETHER",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 120,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: [
//                         _buildSuggestionCard(
//                           "Pain Relief Gel",
//                           "+\$12.00",
//                           Icons.medication,
//                           Colors.blue.shade50,
//                         ),
//                         _buildSuggestionCard(
//                           "BP Checkup",
//                           "+\$15.00",
//                           Icons.monitor_heart,
//                           Colors.purple.shade50,
//                         ),
//                         _buildSuggestionCard(
//                           "Health Tip",
//                           "FREE",
//                           Icons.lightbulb,
//                           Colors.amber.shade50,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   _buildPromoCode(),
//                   const SizedBox(height: 25),
//                   _summaryRow(
//                     "Subtotal (3 items)",
//                     "\$${subtotal.toStringAsFixed(2)}",
//                   ),
//                   _summaryRow(
//                     "Service Fee",
//                     "\$${serviceFee.toStringAsFixed(2)}",
//                   ),
//                   _summaryRow("Tax (5%)", "\$${tax.toStringAsFixed(2)}"),
//                   const Divider(height: 30),
//                   _summaryRow(
//                     "Total",
//                     "\$${total.toStringAsFixed(2)}",
//                     isBold: true,
//                   ),
//                   const SizedBox(height: 120), // Space for checkout button
//                 ],
//               ),
//             ),
//             _buildCheckoutButton(total),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         IconButton(
//           onPressed: () => Get.offAllNamed('/bottomAppBar'),
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//         ),
//         const Text(
//           "My Cart",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         IconButton(
//           onPressed: () {
//             _showOptionsBottomSheet(context);
//           },
//           icon: const Icon(Icons.more_vert, color: Colors.black),
//         ),
//       ],
//     );
//   }

//   Widget _buildDeliveryCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F7FF),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.location_on, color: Colors.blue),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "DELIVER TO",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   "Lucknow Jankipuram Sector-H 20...",
//                   style: TextStyle(fontSize: 14, color: Colors.black87),
//                 ),
//               ],
//             ),
//           ),
//           TextButton(onPressed: () {}, child: const Text("Change")),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartItem(
//     String title,
//     String sub,
//     String price,
//     Color color,
//     IconData icon,
//     int quantity,
//     Function(int) onQtyChanged,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 75,
//             width: 75,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Icon(icon, color: Colors.black45, size: 30),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const Icon(Icons.close, size: 18, color: Colors.grey),
//                   ],
//                 ),
//                 Text(
//                   sub,
//                   style: const TextStyle(color: Colors.grey, fontSize: 13),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       price,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w900,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF5F7FA),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               if (quantity > 1) onQtyChanged(quantity - 1);
//                             },
//                             child: const Icon(
//                               Icons.remove,
//                               size: 16,
//                               color: Colors.blue,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Text(
//                               "$quantity",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => onQtyChanged(quantity + 1),
//                             child: const Icon(
//                               Icons.add,
//                               size: 16,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuggestionCard(
//     String title,
//     String price,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       width: 140,
//       margin: const EdgeInsets.only(right: 15),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 15,
//             backgroundColor: color,
//             child: Icon(icon, size: 16, color: Colors.blue),
//           ),
//           const Spacer(),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 price,
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               const Icon(Icons.add_circle, color: Colors.blue, size: 22),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPromoCode() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey.shade300),
//         color: Colors.white,
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.local_offer_outlined, color: Colors.blue),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Apply Promo Code",
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//           Icon(Icons.chevron_right, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(String label, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 15,
//               color: isBold ? Colors.black : Colors.grey.shade600,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isBold ? 22 : 15,
//               color: isBold ? const Color(0xFF4A90E2) : Colors.black,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckoutButton(double total) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFFF5252),
//             minimumSize: const Size(double.infinity, 60),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             elevation: 5,
//           ),
//           onPressed: () {},
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Checkout",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       "\$${total.toStringAsFixed(2)}",
//                       style: const TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                     const SizedBox(width: 10),
//                     const Icon(Icons.arrow_forward, color: Colors.white),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// void _showOptionsBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true, // 🔥 IMPORTANT
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//     ),
//     builder: (context) {
//       return SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 10,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Handle bar
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Options",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),

//               // Options
//               _optionTile(
//                 Icons.delete_outline,
//                 "Clear Cart",
//                 "Remove all items",
//                 Colors.red.shade50,
//                 Colors.red,
//               ),
//               _optionTile(
//                 Icons.ios_share,
//                 "Share Cart",
//                 "Send list to friends or family",
//                 Colors.blue.shade50,
//                 Colors.blue,
//               ),
//               _optionTile(
//                 Icons.bookmark_border,
//                 "Save for Later",
//                 "Move items to wishlist",
//                 Colors.orange.shade50,
//                 Colors.orange,
//               ),
//               _optionTile(
//                 Icons.support_agent,
//                 "Help & Support",
//                 "Issues with your order?",
//                 Colors.purple.shade50,
//                 Colors.purple,
//               ),

//               const SizedBox(height: 20),

//               // Cancel Button
//               OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 55),
//                   side: BorderSide(color: Colors.grey.shade300),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text(
//                   "Cancel",
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// // Helper Widget for the rows
// Widget _optionTile(
//   IconData icon,
//   String title,
//   String subtitle,
//   Color bgColor,
//   Color iconColor,
// ) {
//   return ListTile(
//     contentPadding: const EdgeInsets.symmetric(vertical: 8),
//     leading: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
//       child: Icon(icon, color: iconColor),
//     ),
//     title: Text(
//       title,
//       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//     ),
//     subtitle: Text(
//       subtitle,
//       style: const TextStyle(color: Colors.grey, fontSize: 13),
//     ),
//     trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//     onTap: () {
//       // Handle action here
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Pages/Cart/widget/cart_app_bar.dart';
import 'package:home_care/Pages/Cart/widget/cart_item.dart';
import 'package:home_care/Pages/Cart/widget/checkout_button.dart';
import 'package:home_care/Pages/Cart/widget/delivery_card.dart';
import 'package:home_care/Pages/Cart/widget/options_bottom_sheet.dart';
import 'package:home_care/Pages/Cart/widget/promo_code.dart';
import 'package:home_care/Pages/Cart/widget/suggestion_card.dart';
import 'package:home_care/Pages/Cart/widget/summary_row.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int qtyPhysio = 1;
  int qtyBaby = 1;
  int qtyRehab = 1;

  @override
  Widget build(BuildContext context) {
    final subtotal = 45 * qtyPhysio + 28.5 * qtyBaby + 60 * qtyRehab;
    final serviceFee = 5.0;
    final tax = subtotal * 0.05;
    final total = subtotal + serviceFee + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CartAppBar(
                    onBack: () => Get.offAllNamed('/bottomAppBar'),
                    onMore: () => showOptionsBottomSheet(context),
                  ),
                  const SizedBox(height: 20),
                  const DeliveryCard(),
                  const SizedBox(height: 20),

                  CartItem(
                    title: "Physiotherapy Session",
                    subtitle: "Dr. Anjali Gupta • 1 Hr",
                    price: "\$45.00",
                    icon: Icons.spa,
                    bgColor: const Color(0xFFE8EAF6),
                    quantity: qtyPhysio,
                    onQtyChanged: (v) => setState(() => qtyPhysio = v),
                  ),
                  CartItem(
                    title: "Premium Baby Care Kit",
                    subtitle: "Includes 5 essentials",
                    price: "\$28.50",
                    icon: Icons.child_care,
                    bgColor: const Color(0xFFFFF3E0),
                    quantity: qtyBaby,
                    onQtyChanged: (v) => setState(() => qtyBaby = v),
                  ),
                  CartItem(
                    title: "Rehabilitation Consult",
                    subtitle: "Video Consultation",
                    price: "\$60.00",
                    icon: Icons.medical_services,
                    bgColor: const Color(0xFFE8F5E9),
                    quantity: qtyRehab,
                    onQtyChanged: (v) => setState(() => qtyRehab = v),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "OFTEN BOOKED TOGETHER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SuggestionCard(
                          title: "Pain Relief Gel",
                          price: "+\$12.00",
                          icon: Icons.medication,
                          color: Colors.blueAccent,
                        ),
                        SuggestionCard(
                          title: "BP Checkup",
                          price: "+\$15.00",
                          icon: Icons.monitor_heart,
                          color: Colors.purple,
                        ),
                        SuggestionCard(
                          title: "Health Tip",
                          price: "FREE",
                          icon: Icons.lightbulb,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const PromoCode(),
                  const SizedBox(height: 25),

                  SummaryRow(label: "Subtotal", value: subtotal),
                  SummaryRow(label: "Service Fee", value: serviceFee),
                  SummaryRow(label: "Tax (5%)", value: tax),
                  const Divider(height: 30),
                  SummaryRow(label: "Total", value: total, isBold: true),

                  const SizedBox(height: 120),
                ],
              ),
            ),
            CheckoutButton(total: total),
          ],
        ),
      ),
    );
  }
}
