// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class BookNowPage extends StatefulWidget {
//   const BookNowPage({super.key});

//   @override
//   State<BookNowPage> createState() => _BookNowPageState();
// }

// class _BookNowPageState extends State<BookNowPage> {
//   int selectedService = -1;
//   bool bookingConfirmed = false;

//   GoogleMapController? mapController;

//   List<String> services = [
//     "Teeth Cleaning",
//     "Root Canal",
//     "Braces Checkup",
//     "Dental Implant",
//     "Teeth Whitening",
//   ];

//   LatLng clinicLocation = const LatLng(19.0760, 72.8777);

//   @override
//   void dispose() {
//     mapController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,

//       appBar: AppBar(
//         title: const Text("Book Now"),
//         centerTitle: true,
//         elevation: 0,
//       ),

//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _doctorSummary(),
//               SizedBox(height: 25.h),

//               // Service Selection
//               _title("Select Service"),
//               SizedBox(height: 10.h),
//               _servicesList(),

//               SizedBox(height: 30.h),

//               // Confirm Button
//               _confirmButton(),

//               SizedBox(height: 30.h),

//               // Live Map (after booking confirm)
//               if (bookingConfirmed) _liveMapSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- Doctor Box ----------------
//   Widget _doctorSummary() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: _boxDecoration(),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 35.r,
//             backgroundColor: Colors.purple.shade100,
//             child: const Icon(Icons.person, color: Colors.purple, size: 35),
//           ),
//           SizedBox(width: 15.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Dr. Mehta",
//                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 "Dentist",
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
//               ),
//               SizedBox(height: 4.h),
//               Row(
//                 children: const [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   SizedBox(width: 5),
//                   Text("4.5"),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _title(String title) {
//     return Text(
//       title,
//       style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//     );
//   }

//   // ---------------- Service List ----------------
//   Widget _servicesList() {
//     return Container(
//       decoration: _boxDecoration(),
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: List.generate(
//           services.length,
//           (i) => InkWell(
//             onTap: () => setState(() => selectedService = i),
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 12.h),
//               child: Row(
//                 children: [
//                   Icon(
//                     selectedService == i
//                         ? Icons.check_circle
//                         : Icons.circle_outlined,
//                     color: selectedService == i ? Colors.purple : Colors.grey,
//                   ),
//                   SizedBox(width: 12.w),
//                   Text(services[i], style: TextStyle(fontSize: 15.sp)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- Confirm Booking ----------------
//   Widget _confirmButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           if (selectedService == -1) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Please select a service.")),
//             );
//             return;
//           }

//           setState(() => bookingConfirmed = true);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.purple,
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: Text(
//           "Book Now",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- Live Map Section ----------------
//   Widget _liveMapSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _title("Live Location"),
//         SizedBox(height: 10.h),

//         Container(
//           height: 320.h,
//           decoration: _boxDecoration(),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12.r),
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: clinicLocation,
//                 zoom: 14,
//               ),
//               markers: {
//                 Marker(
//                   markerId: const MarkerId("clinic"),
//                   position: clinicLocation,
//                   infoWindow: const InfoWindow(title: "Clinic Location"),
//                 ),
//               },
//               onMapCreated: (controller) => mapController = controller,
//               myLocationEnabled: true,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ---------------- Box Decoration ----------------
//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12.r),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black12,
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookNowPage extends StatefulWidget {
  const BookNowPage({super.key});

  @override
  State<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends State<BookNowPage> {
  bool bookingConfirmed = false;
  bool serviceSelected = true; // always true because we show selected service
  bool isChecked = true; // checkbox state

  GoogleMapController? mapController;

  String selectedService = "Teeth Cleaning";

  LatLng clinicLocation = const LatLng(19.0760, 72.8777);

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // ----------------------------- UI -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Book Now"),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _doctorSummary(),
              SizedBox(height: 25.h),

              _title("Selected Service"),
              SizedBox(height: 10.h),

              _selectedServiceBox(),

              SizedBox(height: 30.h),

              _nextButton(),

              SizedBox(height: 30.h),

              if (bookingConfirmed) _liveMapSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Selected Service Box ----------------
  Widget _selectedServiceBox() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (v) {
              setState(() => isChecked = v ?? true);
            },
            activeColor: Colors.purple,
          ),

          // Service Name
          Expanded(
            child: Text(
              selectedService,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                selectedService = "";
                serviceSelected = false;
              });
            },
          ),

          // Add Button
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NextPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- Doctor Box ----------------
  Widget _doctorSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.purple.shade100,
            child: const Icon(Icons.person, color: Colors.purple, size: 35),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dr. Mehta",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                "Dentist",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 4.h),
              Row(
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 5),
                  Text("4.5"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }

  // ---------------- Next Button ----------------
  Widget _nextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (selectedService.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please add a service.")),
            );
            return;
          }

          setState(() => bookingConfirmed = true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------- Live Map Section ----------------
  Widget _liveMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("Live Location"),
        SizedBox(height: 10.h),

        Container(
          height: 320.h,
          decoration: _boxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: clinicLocation,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("clinic"),
                  position: clinicLocation,
                  infoWindow: const InfoWindow(title: "Clinic Location"),
                ),
              },
              onMapCreated: (controller) => mapController = controller,
              myLocationEnabled: true,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Box Decoration ----------------
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// -------------------------- Next Page --------------------------
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Next Page")),
      body: const Center(
        child: Text("Add New Service Page", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
