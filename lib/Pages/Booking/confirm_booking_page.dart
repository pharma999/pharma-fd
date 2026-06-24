import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Pages/Bookings/booking_tracking_page.dart';

class ConfirmBookingPage extends StatefulWidget {
  final String professionalId;
  final String serviceId;
  final String professionalName;
  final String professionalRole;
  final String serviceName;
  final double rating;
  final int yearsExperience;
  final String distance;
  final int estimatedDuration;
  final String availableTimeStart;
  final String availableTimeEnd;
  final double price;

  const ConfirmBookingPage({
    super.key,
    required this.professionalId,
    required this.serviceId,
    required this.professionalName,
    required this.professionalRole,
    required this.serviceName,
    required this.rating,
    required this.yearsExperience,
    required this.distance,
    required this.estimatedDuration,
    required this.availableTimeStart,
    required this.availableTimeEnd,
    this.price = 0,
  });

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _client = ApiClient();

  bool _isProcessing = false;
  bool _fetchingLocation = false;
  bool _loadingServices = false;
  String _paymentMethod = 'CASH';
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  String _latStr = '';
  String _lngStr = '';

  // Inline validation errors
  String? _serviceError;
  String? _addressError;

  // Service selection — used when widget.serviceId is empty
  List<Map<String, dynamic>> _availableServices = [];
  String _selectedServiceId = '';
  String _selectedServiceName = '';

  String get _effectiveServiceId =>
      widget.serviceId.isNotEmpty ? widget.serviceId : _selectedServiceId;
  String get _effectiveServiceName =>
      widget.serviceName.isNotEmpty ? widget.serviceName : _selectedServiceName;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId.isEmpty) _fetchServices();
    // Auto-fetch GPS address so the address field is pre-filled
    _autoFillAddress();
  }

  Future<void> _autoFillAddress() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      setState(() {
        _latStr = pos.latitude.toString();
        _lngStr = pos.longitude.toString();
        if (_addressCtrl.text.trim().isEmpty) {
          _addressCtrl.text =
              'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
          _addressError = null; // clear any inline error once auto-filled
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    setState(() => _loadingServices = true);
    try {
      final res = await _client.get('services', requiresAuth: true);
      final raw = res['data'] ?? res['services'] ?? [];
      final list = (raw is List ? raw : [])
          .whereType<Map>()
          .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
          .toList();
      if (!mounted) return;
      setState(() {
        _availableServices = list;
        // Auto-select the first service that matches the professional's role,
        // falling back to the first service in the list so Confirm always works.
        if (list.isNotEmpty && _selectedServiceId.isEmpty) {
          final roleKey = widget.professionalRole.toLowerCase();
          final match = list.firstWhere(
            (s) => (s['title'] ?? s['name'] ?? '')
                .toString()
                .toLowerCase()
                .contains(roleKey),
            orElse: () => list.first,
          );
          _selectedServiceId = match['service_id'] ?? match['id'] ?? match['_id'] ?? '';
          _selectedServiceName = match['title'] ?? match['name'] ?? '';
          _serviceError = null;
        }
      });
    } catch (_) {
      // Non-fatal — user sees a text field fallback
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          Get.snackbar('Permission Denied',
              'Location permission permanently denied. Please enable it in settings.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900);
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latStr = pos.latitude.toString();
        _lngStr = pos.longitude.toString();
        _addressCtrl.text =
            'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Location Error', e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _confirm() async {
    // Validate with inline errors — visible without dismissal
    bool hasError = false;
    if (_effectiveServiceId.isEmpty) {
      setState(() => _serviceError = 'Please select a service to continue.');
      hasError = true;
    } else {
      setState(() => _serviceError = null);
    }

    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      setState(() => _addressError = 'Please enter your address or use GPS.');
      hasError = true;
    } else {
      setState(() => _addressError = null);
    }

    if (hasError) return;

    setState(() => _isProcessing = true);

    try {
      final scheduledIso = _scheduledAt.toUtc().toIso8601String();
      final body = <String, dynamic>{
        'service_id': _effectiveServiceId,
        'service_name': _effectiveServiceName,
        'professional_id': widget.professionalId,
        'booking_type': 'SCHEDULED',
        'payment_method': _paymentMethod,
        'price': widget.price,
        'scheduled_at': scheduledIso,
        'patient_address': address,
        if (_latStr.isNotEmpty) 'patient_latitude': _latStr,
        if (_lngStr.isNotEmpty) 'patient_longitude': _lngStr,
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      };

      final res = await _client.post('bookings', body, requiresAuth: true);
      final data = res['data'] as Map<String, dynamic>? ?? res as Map<String, dynamic>;
      final bookingId = data['booking_id'] ?? data['id'] ?? data['_id'] ?? '';

      if (bookingId.isEmpty) throw Exception('Booking ID missing in response');

      if (_paymentMethod == 'ONLINE') {
        await _initiateOnlinePayment(bookingId, widget.price);
      }

      if (!mounted) return;
      Get.snackbar(
        'Booking Confirmed!',
        'Your booking has been placed. A professional will be assigned shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
      );

      // Navigate to tracking page
      Get.offAll(() => BookingTrackingPage(
            bookingId: bookingId,
            serviceName: widget.serviceName,
            status: 'PENDING',
          ));
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Booking Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _initiateOnlinePayment(String bookingId, double amount) async {
    try {
      final res = await _client.post('payments/initiate', {
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': 'ONLINE',
      }, requiresAuth: true);

      final paymentId = (res['data'] ?? res)['payment_id'] ?? '';
      if (paymentId.isEmpty) return;

      // For a real integration, open Razorpay/Stripe/UPI here.
      // For now, auto-confirm with a simulated transaction ID.
      await _client.post('payments/$paymentId/confirm', {
        'transaction_id': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'SUCCESS',
      });
    } catch (_) {}
  }

  String _fmtDate(DateTime dt) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} • $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Confirm Booking',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF312E81),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfessionalCard(),
            const SizedBox(height: 16),
            if (widget.serviceId.isEmpty) ...[
              _buildServicePickerSection(),
              const SizedBox(height: 16),
            ],
            _buildAddressSection(),
            const SizedBox(height: 16),
            _buildScheduleSection(),
            const SizedBox(height: 16),
            _buildPaymentSection(),
            const SizedBox(height: 16),
            _buildNotesSection(),
            const SizedBox(height: 16),
            _buildPriceSummary(),
            const SizedBox(height: 24),
            _buildConfirmButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.indigo.shade600]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.professionalName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF312E81))),
                Text(widget.professionalRole,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text('${widget.rating}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Icon(Icons.medical_services_outlined,
                        size: 14, color: Colors.blue.shade400),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(widget.serviceName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue.shade600),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.price > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${widget.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF312E81))),
                Text('per visit',
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildServicePickerSection() {
    return _sectionCard(
      title: 'Select Service *',
      icon: Icons.medical_services_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingServices)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_availableServices.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No services loaded. Enter a service name to continue.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'e.g. Home Nursing, Physiotherapy...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixIcon: const Icon(
                        Icons.medical_services_outlined, size: 18),
                  ),
                  onChanged: (v) => setState(() {
                    _selectedServiceName = v.trim();
                    if (v.trim().isNotEmpty) _serviceError = null;
                  }),
                ),
              ],
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedServiceId.isEmpty ? null : _selectedServiceId,
              hint: const Text('Choose a service'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                prefixIcon: const Icon(
                    Icons.medical_services_outlined, size: 18),
              ),
              items: _availableServices.map((svc) {
                final id =
                    svc['service_id'] ?? svc['id'] ?? svc['_id'] ?? '';
                final name = svc['title'] ?? svc['name'] ?? '';
                final price =
                    (svc['base_price'] ?? svc['price'] ?? 0).toDouble();
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    price > 0
                        ? '$name  ·  ₹${price.toStringAsFixed(0)}'
                        : name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final svc = _availableServices.firstWhere(
                    (s) =>
                        (s['service_id'] ?? s['id'] ?? s['_id']) == id,
                    orElse: () => {});
                setState(() {
                  _selectedServiceId = id;
                  _selectedServiceName = svc['title'] ?? svc['name'] ?? '';
                  _serviceError = null;
                });
              },
            ),
          if (_serviceError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.red),
                const SizedBox(width: 6),
                Text(_serviceError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return _sectionCard(
      title: 'Your Address *',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _addressCtrl,
            onChanged: (_) {
              if (_addressError != null && _addressCtrl.text.trim().isNotEmpty) {
                setState(() => _addressError = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your full address...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _addressError != null ? Colors.red : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _addressError != null ? Colors.red : Colors.grey.shade300,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: _fetchingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                      tooltip: 'Use current location',
                      onPressed: _useCurrentLocation,
                    ),
            ),
            maxLines: 2,
          ),
          if (_addressError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 14, color: Colors.red),
                const SizedBox(width: 6),
                Text(_addressError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ]),
            ),
          if (_latStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text('GPS coordinates captured',
                      style: TextStyle(
                          fontSize: 11, color: Colors.green.shade700)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return _sectionCard(
      title: 'Schedule',
      icon: Icons.calendar_today_outlined,
      child: InkWell(
        onTap: _pickDateTime,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_fmtDate(_scheduledAt),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Icon(Icons.edit_outlined,
                  size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _sectionCard(
      title: 'Payment Method',
      icon: Icons.payment_outlined,
      child: Row(
        children: [
          Expanded(child: _paymentOption('CASH', Icons.money, 'Cash on Service')),
          const SizedBox(width: 10),
          Expanded(
              child: _paymentOption('ONLINE', Icons.account_balance_wallet_outlined,
                  'Pay Online')),
        ],
      ),
    );
  }

  Widget _paymentOption(String value, IconData icon, String label) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFF2563EB)
                    : Colors.grey.shade500,
                size: 24),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _sectionCard(
      title: 'Notes (Optional)',
      icon: Icons.notes_outlined,
      child: TextField(
        controller: _notesCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Any special instructions or health conditions...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF312E81),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _summaryRow('Service', _effectiveServiceName.isNotEmpty ? _effectiveServiceName : '—'),
          _summaryRow('Professional', widget.professionalName),
          _summaryRow('Duration', '${widget.estimatedDuration} min'),
          _summaryRow('Payment', _paymentMethod == 'CASH' ? 'Cash' : 'Online'),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                widget.price > 0 ? '₹${widget.price.toStringAsFixed(2)}' : 'As quoted',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BC4FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _paymentMethod == 'ONLINE'
                        ? 'Confirm & Pay ₹${widget.price.toStringAsFixed(0)}'
                        : 'Confirm Booking',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF312E81)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF312E81))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
