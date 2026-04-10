import 'package:get/get.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

/// Model for Professional
class Professional {
  final String id;
  final String name;
  final String role;
  final String serviceName;
  final String distance;
  final double rating;
  final bool available;
  final String imageUrl;
  final int yearsExperience;
  final int estimatedDuration; // in minutes
  final String availableTimeStart; // e.g., "2:00 PM"
  final String availableTimeEnd; // e.g., "4:00 PM"

  Professional({
    required this.id,
    required this.name,
    required this.role,
    required this.serviceName,
    required this.distance,
    required this.rating,
    required this.available,
    this.imageUrl = '',
    this.yearsExperience = 0,
    this.estimatedDuration = 30,
    this.availableTimeStart = '2:00 PM',
    this.availableTimeEnd = '4:00 PM',
  });
}

/// Controller to manage service and professional selection
class ServiceProfessionalsController extends GetxController {
  RxString selectedService = ''.obs;
  RxString selectedServiceTitle = 'All Services'.obs;
  RxList<Professional> filteredProfessionals = <Professional>[].obs;

  // All professionals data
  final List<Professional> allProfessionals = [
    Professional(
      id: '1',
      name: 'Nurse Sharma',
      role: 'Senior Nurse',
      serviceName: 'Nursing Care',
      distance: '2.5 km away',
      rating: 4.8,
      available: true,
      yearsExperience: 8,
      estimatedDuration: 30,
      availableTimeStart: '9:00 AM',
      availableTimeEnd: '11:00 AM',
    ),
    Professional(
      id: '2',
      name: 'Dr. Patel',
      role: 'Physiotherapist',
      serviceName: 'Physiotherapy',
      distance: '3.2 km away',
      rating: 4.6,
      available: true,
      yearsExperience: 6,
      estimatedDuration: 45,
      availableTimeStart: '10:00 AM',
      availableTimeEnd: '12:00 PM',
    ),
    Professional(
      id: '3',
      name: 'Dr. Singh',
      role: 'General Physician',
      serviceName: 'Checkups',
      distance: '1.9 km away',
      rating: 4.9,
      available: false,
      yearsExperience: 12,
      estimatedDuration: 20,
      availableTimeStart: '2:00 PM',
      availableTimeEnd: '4:00 PM',
    ),
    Professional(
      id: '4',
      name: 'Nurse Riya',
      role: 'Staff Nurse',
      serviceName: 'Nursing Care',
      distance: '4.2 km away',
      rating: 4.7,
      available: true,
      yearsExperience: 5,
      estimatedDuration: 25,
      availableTimeStart: '11:00 AM',
      availableTimeEnd: '1:00 PM',
    ),
    Professional(
      id: '5',
      name: 'Dr. Mehta',
      role: 'Dentist',
      serviceName: 'Emergency',
      distance: '2.0 km away',
      rating: 4.5,
      available: true,
      yearsExperience: 7,
      estimatedDuration: 15,
      availableTimeStart: '1:00 PM',
      availableTimeEnd: '3:00 PM',
    ),
    Professional(
      id: '6',
      name: 'Dr. Kapoor',
      role: 'Dermatologist',
      serviceName: 'Mental Health',
      distance: '5.0 km away',
      rating: 4.4,
      available: false,
      yearsExperience: 10,
      estimatedDuration: 40,
      availableTimeStart: '3:00 PM',
      availableTimeEnd: '5:00 PM',
    ),
    Professional(
      id: '7',
      name: 'Dr. Verma',
      role: 'Therapist',
      serviceName: 'Therapy',
      distance: '3.5 km away',
      rating: 4.8,
      available: true,
      yearsExperience: 9,
      estimatedDuration: 50,
      availableTimeStart: '9:30 AM',
      availableTimeEnd: '11:30 AM',
    ),
    Professional(
      id: '8',
      name: 'Baby Specialist Kumar',
      role: 'Pediatrician',
      serviceName: 'Baby Care',
      distance: '2.8 km away',
      rating: 4.9,
      available: true,
      yearsExperience: 11,
      estimatedDuration: 35,
      availableTimeStart: '2:30 PM',
      availableTimeEnd: '4:30 PM',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    LoggerService.info('ServiceProfessionalsController initialized');
    // Load all professionals by default
    filteredProfessionals.assignAll(allProfessionals);
  }

  /// Select a service and filter professionals
  void selectService(String serviceId, String serviceTitle) {
    selectedService.value = serviceId;
    selectedServiceTitle.value = serviceTitle;
    LoggerService.info('Selected service: $serviceTitle');

    // Filter professionals by selected service
    if (serviceId.isEmpty) {
      filteredProfessionals.assignAll(allProfessionals);
    } else {
      final filtered = allProfessionals
          .where(
            (pro) => pro.serviceName.toLowerCase().contains(
              serviceTitle.toLowerCase(),
            ),
          )
          .toList();
      filteredProfessionals.assignAll(filtered);
      LoggerService.info(
        'Filtered ${filtered.length} professionals for service: $serviceTitle',
      );
    }
  }

  /// Clear service selection (show all)
  void clearServiceSelection() {
    selectedService.value = '';
    selectedServiceTitle.value = 'All Services';
    filteredProfessionals.assignAll(allProfessionals);
    LoggerService.info('Cleared service selection - showing all professionals');
  }

  /// View professional profile
  void viewProfile(String professionalId) {
    LoggerService.info('Viewing profile for professional: $professionalId');
    final professional = allProfessionals.firstWhere(
      (p) => p.id == professionalId,
      orElse: () => allProfessionals.first,
    );
    Get.to(
      () => ProfessionalDetailPage(
        professionalId: professional.id,
        name: professional.name,
        role: professional.role,
        serviceName: professional.serviceName,
        rating: professional.rating,
        available: professional.available,
        yearsExperience: professional.yearsExperience,
        distance: professional.distance,
        estimatedDuration: professional.estimatedDuration,
        availableTimeStart: professional.availableTimeStart,
        availableTimeEnd: professional.availableTimeEnd,
      ),
    );
  }

  /// Book appointment
  void bookAppointment(String professionalId, String professionalName) {
    LoggerService.info(
      'Booking appointment with professional: $professionalName ($professionalId)',
    );
    final professional = allProfessionals.firstWhere(
      (p) => p.id == professionalId,
      orElse: () => allProfessionals.first,
    );
    Get.to(
      () => ProfessionalDetailPage(
        professionalId: professional.id,
        name: professional.name,
        role: professional.role,
        serviceName: professional.serviceName,
        rating: professional.rating,
        available: professional.available,
        yearsExperience: professional.yearsExperience,
        distance: professional.distance,
        estimatedDuration: professional.estimatedDuration,
        availableTimeStart: professional.availableTimeStart,
        availableTimeEnd: professional.availableTimeEnd,
      ),
    );
  }
}
