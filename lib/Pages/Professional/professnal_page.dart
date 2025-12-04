import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfessionalPage extends StatelessWidget {
  const ProfessionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> doctor = {
      'name': 'Dr. Mehta',
      'role': 'Dentist',
      'distance': '2.0 km away',
      'rating': 4.5,
      'available': true,
      'experience': '12 years of clinical experience',
      'about':
          'Dr. Mehta is an experienced dentist known for painless treatments, '
          'modern dental procedures, and patient-friendly care.',
      'services': [
        'Teeth Cleaning',
        'Root Canal Treatment',
        'Dental Implants',
        'Teeth Whitening',
        'Braces & Aligners',
      ],
      'fees': '₹500 Consultation',
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        leading: IconButton(
          onPressed: () => Get.offAllNamed("/bottomAppBar"),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text("Doctor Profile"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45.r,
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(
                        Icons.person,
                        size: 50.sp,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Name
                    Text(
                      doctor['name'] as String,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Role
                    Text(
                      doctor['role'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.star, color: Colors.amber, size: 20),
                        SizedBox(width: 5.w),
                        Text(
                          doctor['rating'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Icon(Iconsax.location, size: 20),
                        SizedBox(width: 5.w),
                        Text(doctor['distance'] as String),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Chip(
                      label: Text(
                        (doctor['available'] as bool)
                            ? "Available Today"
                            : "Unavailable",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: (doctor['available'] as bool)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              sectionTitle("Experience"),
              sectionBox(doctor['experience'] as String),

              SizedBox(height: 20.h),

              sectionTitle("About Doctor"),
              sectionBox(doctor['about'] as String),

              SizedBox(height: 20.h),

              sectionTitle("Services"),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (doctor['services'] as List).length,
                    (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            size: 20,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            (doctor['services'] as List<String>)[index],
                            style: TextStyle(fontSize: 15.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      child: Text(
                        "Book Appointment",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget sectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget sectionBox(String text, {bool center = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: boxDecoration(),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(fontSize: 15.sp),
      ),
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    );
  }
}
