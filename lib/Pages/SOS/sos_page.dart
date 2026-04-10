import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  // Mock nearby hospitals with coordinates (in real app, use actual API)
  final List<Hospital> nearbyHospitals = [
    Hospital(
      id: '1',
      name: 'City General Hospital',
      address: 'Sector H, Jankipuram, Lucknow',
      phone: '+91-9876543210',
      latitude: 26.8124,
      longitude: 80.9421,
      distance: 0.5,
      emergency: true,
    ),
    Hospital(
      id: '2',
      name: 'Apollo Hospitals',
      address: 'Gomti Nagar, Lucknow',
      phone: '+91-9876543211',
      latitude: 26.8297,
      longitude: 80.9859,
      distance: 2.3,
      emergency: true,
    ),
    Hospital(
      id: '3',
      name: 'Max Healthcare',
      address: 'Aliganj, Lucknow',
      phone: '+91-9876543212',
      latitude: 26.8475,
      longitude: 80.9489,
      distance: 3.1,
      emergency: false,
    ),
    Hospital(
      id: '4',
      name: 'Medanta Hospital',
      address: 'Charbagh, Lucknow',
      phone: '+91-9876543213',
      latitude: 26.8245,
      longitude: 80.9167,
      distance: 4.2,
      emergency: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _errorMessage = 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _callHospital(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar('Error', 'Could not launch phone call');
    }
  }

  void _openMaps(Hospital hospital) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {
        'api': '1',
        'query': '${hospital.latitude},${hospital.longitude}',
      },
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar('Error', 'Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: const Text(
          'Emergency SOS',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00BCD4), Color(0xFF006064)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emergency Alert Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: const Color(0xFF00BCD4),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Emergency Services',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00BCD4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find nearest hospital and call for help',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF00BCD4)
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Location Info
                  if (_currentPosition != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Nearest Hospitals Title
                  const Text(
                    'Nearby Hospitals (Emergency)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Hospital List
                  ...nearbyHospitals
                      .where((h) => h.emergency)
                      .map((hospital) => _buildHospitalCard(hospital))
                      .toList(),

                  const SizedBox(height: 20),

                  // Other Hospitals
                  const Text(
                    'Other Nearby Hospitals',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  ...nearbyHospitals
                      .where((h) => !h.emergency)
                      .map((hospital) => _buildHospitalCard(hospital))
                      .toList(),

                  const SizedBox(height: 20),

                  // Quick Emergency Number
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF006064)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'National Emergency Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _callHospital('102'),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              '102 - Ambulance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Location Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unable to access your location',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hospital.emergency
              ? const Color(0xFF00BCD4)
              : Colors.grey.shade200,
          width: hospital.emergency ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hospital.emergency
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_hospital,
                  color: hospital.emergency ? Colors.red : Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hospital.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hospital.emergency)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '24/7',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF00BCD4),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital.address,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.navigation,
                          size: 14,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hospital.distance} km away',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callHospital(hospital.phone),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openMaps(hospital),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Hospital {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double distance;
  final bool emergency;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.emergency,
  });
}
