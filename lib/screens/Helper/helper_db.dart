import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

import '../../controllers/auth_controller.dart';
import '../../models/sos_requestmodel.dart';
import '../../resources/AppTheme.dart';

class HelperDashboard extends StatefulWidget {
  const HelperDashboard({super.key});

  @override
  State<HelperDashboard> createState() => _HelperDashboardState();
}

class _HelperDashboardState extends State<HelperDashboard> {
  final _authController = Get.find<AuthController>();
  bool _isAvailable = true;
  int _currentTab = 0;
  String _currentLocationName = 'Fetching location...';
  double? _helperLat;
  double? _helperLng;

  @override
  void initState() {
    super.initState();
    _loadHelperData();
  }

  void _loadHelperData() async {
    final user = _authController.userModel.value;
    if (user != null) {
      // Load from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('helpers')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _isAvailable = data['isAvailable'] ?? true;
          _helperLat = (data['latitude'] as num?)?.toDouble();
          _helperLng = (data['longitude'] as num?)?.toDouble();
        });
      }

      // Try geocoding the stored location
      if (_helperLat != null && _helperLng != null) {
        _reverseGeocode(_helperLat!, _helperLng!);
      } else {
        _fetchCurrentLocation();
      }
    }
  }

  void _fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _currentLocationName = 'Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      _helperLat = pos.latitude;
      _helperLng = pos.longitude;

      // Save to Firestore
      final user = _authController.userModel.value;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('helpers')
            .doc(user.uid)
            .update({'latitude': pos.latitude, 'longitude': pos.longitude});
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'latitude': pos.latitude, 'longitude': pos.longitude});
      }

      _reverseGeocode(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() => _currentLocationName = 'Could not get location');
    }
  }

  void _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _currentLocationName =
          '${p.subLocality ?? p.locality ?? ''}, ${p.locality ?? p.administrativeArea ?? ''}';
        });
      }
    } catch (e) {
      setState(() => _currentLocationName = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}');
    }
  }

  void _toggleAvailability(bool val) async {
    final user = _authController.userModel.value;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('helpers')
          .doc(user.uid)
          .update({'isAvailable': val});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isAvailable': val});
      setState(() => _isAvailable = val);
      Get.snackbar(
        val ? 'You\'re Online 🟢' : 'You\'re Offline ⚪',
        val ? 'You will now receive SOS alerts.' : 'You will not receive alerts.',
        backgroundColor: val ? AppColors.success : AppColors.textHint,
        colorText: Colors.white,
      );
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double deg) => deg * pi / 180;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

     Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${_authController.userFirstName}! 🤝',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Lato')),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(_currentLocationName,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _fetchCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),


          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _isAvailable ? const Color(0xFFE8F8F0) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isAvailable ? AppColors.success : Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(color: _isAvailable ? AppColors.success : Colors.grey, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(_isAvailable ? 'Available for requests' : 'Currently offline',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _isAvailable ? AppColors.success : Colors.grey)),
                ]),
                Switch(value: _isAvailable, onChanged: _toggleAvailability, activeColor: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('🚨 Nearby SOS Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Lato')),
          const SizedBox(height: 12),
          _buildLiveSOSList(),
        ],
      ),
    );
  }

  Widget _buildLiveSOSList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sos_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Text('✅', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('No pending requests nearby', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('All clear for now!', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              ],
            ),
          );
        }

          List<SOSRequest> requests = docs.map((d) => SOSRequest.fromFirestore(d)).toList();
        if (_helperLat != null && _helperLng != null) {
          requests = requests.where((r) {
            final dist = _calculateDistance(_helperLat!, _helperLng!, r.latitude, r.longitude);
            return dist <= 50; // Within 50 km
          }).toList();
        }

        if (requests.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Text('📍', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text('No requests in your area', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return Column(
          children: requests.map((req) => _buildSOSCard(req)).toList(),
        );
      },
    );
  }

  Widget _buildSOSCard(SOSRequest req) {
    final riskColor = req.riskLevel == 'High'
        ? AppColors.urgent
        : (req.riskLevel == 'Medium' ? AppColors.warning : AppColors.success);

    double? distKm;
    if (_helperLat != null && _helperLng != null) {
      distKm = _calculateDistance(_helperLat!, _helperLng!, req.latitude, req.longitude);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: riskColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Risk badge + time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: riskColor, borderRadius: BorderRadius.circular(12)),
                  child: Text('🚨 ${req.riskLevel?.toUpperCase() ?? "UNKNOWN"} RISK',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                Text(_timeAgo(req.timestamp), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Patient name
            Text(req.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),

            // Symptoms
            if (req.symptoms != null && req.symptoms!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text('"${req.symptoms}"',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary, fontSize: 14)),
              ),
            const SizedBox(height: 10),

            // Distance
            if (distKm != null)
              Row(children: [
                const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('${distKm.toStringAsFixed(1)} km away',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),

            const SizedBox(height: 14),

            // Accept button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _acceptRequest(req),
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Accept & Help', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(SOSRequest req) async {
    final user = _authController.userModel.value;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('sos_requests').doc(req.id).update({
      'status': 'accepted',
      'helperId': user.uid,
      'helperName': user.name,
      'helperPhone': user.phoneNumber ?? '',
      'helperType': user.helperType?.name ?? 'other',
      'helperAddress': user.address ?? '',
      'helperLat': _helperLat,
      'helperLng': _helperLng,
    });

    if (mounted) {
      Get.snackbar('Accepted! 🙏', 'You are now helping ${req.patientName}.',
          backgroundColor: AppColors.success, colorText: Colors.white);
    }
  }

    Widget _buildProfile() {
    final user = _authController.userModel.value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF089A97)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                _authController.userFirstName.isNotEmpty ? _authController.userFirstName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_authController.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Lato')),
          const SizedBox(height: 4),
          Text(_authController.userEmail, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Text(user?.helperTypeLabel ?? 'Helper',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 32),

          _profileField(Icons.phone, 'Phone', user?.phoneNumber ?? '—'),
          _profileField(Icons.location_on, 'Location', user?.address ?? _currentLocationName),
          _profileField(Icons.description, 'About', user?.description ?? '—'),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _authController.logout(),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileField(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _currentTab == 0 ? _buildHome() : _buildProfile(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          backgroundColor: AppColors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}