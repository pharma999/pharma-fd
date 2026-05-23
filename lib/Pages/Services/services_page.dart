import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Api/Services/service_repository.dart';
import 'package:home_care/Api/Services/admin_repository.dart';
import 'package:home_care/Model/admin_model.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/Professionals/professionals_list_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final ServiceRepository _repo = ServiceRepository();
  final AdminRepository _adminRepo = AdminRepository();
  final TextEditingController _search = TextEditingController();

  List<ServiceModel> _all = [];
  List<ServiceModel> _filtered = [];
  List<ServiceZone> _zones = [];
  bool _loading = true;
  String? _error;

  // Zone picked by user (shown as a chip / dropdown)
  String _selectedZoneId = '';
  String _selectedZoneName = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadZones();
    _search.addListener(_applySearch);
  }

  Future<void> _loadZones() async {
    final result = await _adminRepo.listZones(status: 'ACTIVE');
    result.when(
      onSuccess: (zones) => setState(() => _zones = zones),
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _search.removeListener(_applySearch);
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() { _loading = true; _error = null; });
    final result = await _repo.getAllServices();
    result.when(
      onSuccess: (data) => setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
      }),
      onError: (err) => setState(() {
        _error = err;
        _loading = false;
      }),
    );
  }

  void _applySearch() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((s) => s.name.toLowerCase().contains(q)).toList();
    });
  }

  void _openProfessionals(ServiceModel service) {
    final profCtrl = Get.find<ServiceProfessionalsController>();
    profCtrl.selectService(
      service.id,
      service.name,
      zoneId: _selectedZoneId.isEmpty ? null : _selectedZoneId,
    );
    Get.to(() => ProfessionalsListPage(
      serviceId: service.id,
      serviceTitle: service.name,
    ));
  }

  static const _iconMap = <String, IconData>{
    'nursing': Icons.health_and_safety,
    'physio': Icons.fitness_center,
    'elder': Icons.elderly,
    'mental': Icons.psychology,
    'lab': Icons.biotech,
    'emergency': Icons.emergency,
    'doctor': Icons.local_hospital,
    'caregiver': Icons.favorite,
    'surgery': Icons.medical_services,
    'maternity': Icons.child_care,
  };

  static const _colorList = [
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
    Color(0xFF2E7D32),
    Color(0xFFE65100),
    Color(0xFFC62828),
    Color(0xFF00838F),
    Color(0xFF4527A0),
    Color(0xFF37474F),
    Color(0xFF558B2F),
  ];

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _iconMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.medical_services;
  }

  Color _colorFor(int index) => _colorList[index % _colorList.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Healthcare Services',
            style: TextStyle(color: Color(0xFF312E81), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadServices,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search services...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          // Zone filter row
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: _selectedZoneName.isEmpty
                    ? GestureDetector(
                        onTap: _pickZone,
                        child: Text(
                          'Select your zone for nearby professionals',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    : GestureDetector(
                        onTap: _pickZone,
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.map_outlined, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(_selectedZoneName,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              const Icon(Icons.close, size: 14, color: Colors.blue),
                            ]),
                          ),
                        ]),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadServices, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No services found', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _ServiceCard(
        service: _filtered[i],
        icon: _iconFor(_filtered[i].name),
        color: _colorFor(i),
        zoneName: _selectedZoneName,
        onBookNow: () => _openProfessionals(_filtered[i]),
      ),
    );
  }

  void _pickZone() {
    if (_zones.isEmpty) {
      // Fallback: text input when zones aren't loaded
      final TextEditingController zoneCtrl = TextEditingController(text: _selectedZoneName);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Enter your zone / city'),
          content: TextField(
            controller: zoneCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. Lucknow',
              prefixIcon: Icon(Icons.location_city),
            ),
            autofocus: true,
          ),
          actions: [
            if (_selectedZoneName.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() { _selectedZoneId = ''; _selectedZoneName = ''; });
                  Navigator.pop(context);
                },
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedZoneName = zoneCtrl.text.trim();
                  _selectedZoneId = zoneCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Select Zone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_selectedZoneId.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() { _selectedZoneId = ''; _selectedZoneName = ''; });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          LimitedBox(
            maxHeight: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _zones.length,
              itemBuilder: (_, i) {
                final z = _zones[i];
                final selected = z.id == _selectedZoneId;
                return ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: selected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(z.name),
                  subtitle: Text('${z.city}, ${z.state}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedZoneId = z.id;
                      _selectedZoneName = z.name;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final IconData icon;
  final Color color;
  final String zoneName;
  final VoidCallback onBookNow;

  const _ServiceCard({
    required this.service,
    required this.icon,
    required this.color,
    required this.zoneName,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    radius: 24,
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF312E81),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.basePrice > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '₹${service.basePrice.toStringAsFixed(0)}/visit',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  zoneName.isEmpty ? 'See Professionals' : 'Book in $zoneName',
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
