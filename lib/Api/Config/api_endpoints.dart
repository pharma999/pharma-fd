class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String sendOtp = "auth/send-otp";
  static const String verifyOtp = "auth/verify-otp";
  static const String login = "auth/send-otp";   // legacy alias
  static const String verify = "auth/verify-otp"; // legacy alias

  // ── User (userId required in path) ───────────────────────────────────────
  static String userProfile(String userId) => "user/$userId";
  static String updateProfile(String userId) => "user/$userId/update";
  static String updateAddress(String userId) => "user/$userId/address/update";
  static String deleteAccount(String userId) => "user/$userId/delete";
  static const String familyMembers = "family/members";
  static const String addFamilyMember = "family/members";

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notifications = "notifications";
  static String markNotificationRead(String id) => "notifications/$id/read";  // PATCH
  static const String markAllNotificationsRead = "notifications/read-all";    // PATCH

  // ── Doctors ───────────────────────────────────────────────────────────────
  static const String searchDoctors = "doctors";          // GET with query params
  static String doctorProfile(String id) => "doctors/$id";
  static String doctorSchedule(String id) => "doctors/$id/schedule";

  // ── Nurses ────────────────────────────────────────────────────────────────
  static const String searchNurses = "nurses";            // GET with query params
  static String nurseProfile(String id) => "nurses/$id";

  // ── Services / Categories / Professionals ────────────────────────────────
  static const String serviceCategories = "categories";
  static const String allServices = "services";
  static String categoryServices(String id) => "categories/$id/services";
  static String serviceDetail(String id) => "services/$id";
  static String serviceProfessionals(String id) => "professionals";  // GET /professionals
  static String professionalDetail(String id) => "professionals/$id";
  static const String submitReview = "reviews";           // POST — professional_id in body

  // ── Appointments ──────────────────────────────────────────────────────────
  static const String createAppointment = "appointments";
  static const String myAppointments = "appointments";
  static String appointmentDetail(String id) => "appointments/$id";
  static String updateAppointmentStatus(String id) => "appointments/$id/status"; // PATCH
  static String cancelAppointment(String id) => "appointments/$id/cancel";
  static const String prescriptions = "prescriptions";
  // Family appointments require patientId — use family/patient/:id/appointments
  static String familyAppointments(String patientId) =>
      "family/patient/$patientId/appointments";

  // ── Bookings ──────────────────────────────────────────────────────────────
  static const String createBooking = "bookings";
  static const String myBookings = "bookings";
  static String bookingDetail(String id) => "bookings/$id";
  static String cancelBooking(String id) => "bookings/$id/cancel";

  // ── Cart ──────────────────────────────────────────────────────────────────
  static const String cart = "cart";
  static const String addToCart = "cart/add";              // POST
  static const String updateCartQuantity = "cart/update-quantity"; // POST — body: {item_id, quantity}
  static String removeCartItem(String serviceId) => "cart/$serviceId"; // DELETE
  // clearCart → DELETE "cart" (use _client.delete(ApiEndpoints.cart))

  // ── Checkout / Payments ───────────────────────────────────────────────────
  static const String checkoutCart = "cart/checkout";
  static const String initiatePayment = "payments/initiate";
  static String confirmPayment(String paymentId) => "payments/$paymentId/confirm";
  static const String paymentHistory = "payments/history";

  // ── Emergency / SOS ───────────────────────────────────────────────────────
  static const String triggerSOS = "emergency/sos";
  static const String myEmergencies = "emergency";
  static String emergencyDetail(String id) => "emergency/$id";

  // ── Medical Records ───────────────────────────────────────────────────────
  static const String medicalRecords = "medical-records";
  static const String uploadMedicalRecord = "medical-records";
  static String deleteMedicalRecord(String id) => "medical-records/$id";
  static String familyMedicalRecords(String patientId) =>
      "family/patient/$patientId/records";

  // ── Hospitals ─────────────────────────────────────────────────────────────
  static const String nearbyHospitals = "hospitals";
  static String hospitalDetail(String id) => "hospitals/$id";
  static String hospitalDoctors(String id) => "hospitals/$id/doctors";

  // ── Support ───────────────────────────────────────────────────────────────
  static const String createTicket = "support";
  static const String myTickets = "support";

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminAnalytics = "admin/analytics";
  static const String adminUsers = "admin/users";
  static String adminUser(String id) => "admin/users/$id";
  static String adminBlockUser(String id) => "admin/users/$id/block";       // PATCH

  static const String adminDoctors = "admin/doctors";
  static String adminApproveDoctor(String id) => "admin/doctors/$id/approval"; // PATCH

  static const String adminNurses = "admin/nurses";
  static String adminApproveNurse(String id) => "admin/nurses/$id/approval";   // PATCH

  static const String adminHospitals = "admin/hospitals";
  static String adminApproveHospital(String id) =>
      "admin/hospitals/$id/approval";                                            // PATCH

  static const String adminBookings = "admin/bookings";
  static String adminUpdateBooking(String id) =>
      "admin/bookings/$id/status";                                               // PATCH

  static const String adminAppointments = "admin/appointments";

  static const String adminActiveEmergencies = "admin/emergencies/active";
  static String adminUpdateEmergency(String id) =>
      "admin/emergencies/$id/status";                                            // PATCH

  static const String adminSupportTickets = "admin/support";
  static String adminSupportTicket(String id) => "admin/support/$id";           // PATCH

  static const String adminPlans = "admin/plans";
  static String adminPlan(String id) => "admin/plans/$id";
  static const String adminSubscriptions = "admin/subscriptions";

  static const String adminZones = "admin/zones";
  static String adminZone(String id) => "admin/zones/$id";

  static const String adminCreateCategory = "admin/categories";
  static const String adminCreateService = "admin/services";
  static String adminUpdateService(String id) => "admin/services/$id";

  // ── Super Admin ───────────────────────────────────────────────────────────
  static const String superAdminRevenue = "super-admin/revenue";
  static const String superAdminAdmins = "super-admin/admins";
  static String superAdminDeleteAdmin(String id) => "super-admin/admins/$id";
  static const String superAdminSettings = "super-admin/settings";

  // ── Chatbot ───────────────────────────────────────────────────────────────
  static const String chatbotMessage = "chatbot/message";
  static const String chatbotHistory = "chatbot/history";

  // ── Ambulance real-time location ──────────────────────────────────────────
  static String ambulanceLocation(String id) => "ambulances/$id/location";

  // ── WebSocket ─────────────────────────────────────────────────────────────
  // Replace https:// with wss:// (or http:// with ws://) at runtime.
  static String wsEndpoint(String token, {String rooms = ''}) {
    final roomsParam = rooms.isNotEmpty ? '&rooms=$rooms' : '';
    return 'ws?token=$token$roomsParam';
  }
}
