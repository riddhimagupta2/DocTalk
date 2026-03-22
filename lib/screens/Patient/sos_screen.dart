import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import '../../controllers/auth_controller.dart';
import '../../models/sos_requestmodel.dart';
import '../../resources/AppTheme.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  final _authController = Get.find<AuthController>();
  final _symptomsController = TextEditingController();
  String _selectedRisk = 'High';
  bool _isSending = false;
  bool _isSent = false;
  String? _activeRequestId;
  int _countdown = 5;
  Timer? _countdownTimer;

  double _patientLat = 0;
  double _patientLng = 0;
  String _locationName = 'Getting your location...';
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationName = 'Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      _patientLat = pos.latitude;
      _patientLng = pos.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          if (mounted) {
            setState(() {
              _locationName = '${p.subLocality ?? p.locality ?? ''}, ${p.locality ?? p.administrativeArea ?? ''}';
              _locationReady = true;
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _locationName = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
            _locationReady = true;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _locationName = 'Could not detect location');
    }
  }

  void _startCountdown() {
    if (_symptomsController.text.trim().isEmpty) {
      Get.snackbar('Missing Info', 'Please describe your symptoms.',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    if (!_locationReady) {
      Get.snackbar('Wait', 'Still detecting your location...',
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }

    setState(() { _isSending = true; _countdown = 5; });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _sendSOS();
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() { _isSending = false; _countdown = 5; });
  }

  Future<void> _sendSOS() async {
    final user = _authController.userModel.value;
    if (user == null) return;

    final request = SOSRequest(
      id: '',
      patientId: user.uid,
      patientName: user.name,
      patientPhone: user.phoneNumber,
      latitude: _patientLat,
      longitude: _patientLng,
      symptoms: _symptomsController.text.trim(),
      riskLevel: _selectedRisk,
      status: RequestStatus.pending,
      timestamp: DateTime.now(),
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('sos_requests')
          .add(request.toFirestore());

      setState(() {
        _isSent = true;
        _activeRequestId = docRef.id;
      });
    } catch (e) {
      Get.snackbar('Error', 'Could not send SOS. Please try again.',
          backgroundColor: AppColors.error, colorText: Colors.white);
      setState(() => _isSending = false);
    }
  }

  void _cancelSOS() async {
    if (_activeRequestId != null) {
      await FirebaseFirestore.instance
          .collection('sos_requests')
          .doc(_activeRequestId)
          .update({'status': 'cancelled'});
    }
    setState(() {
      _isSent = false;
      _isSending = false;
      _activeRequestId = null;
      _symptomsController.clear();
    });
  }

  // ── FORM ──
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFC0392B)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFFE74C3C).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                const Text('🚨', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emergency SOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Lato')),
                      const SizedBox(height: 4),
                      const Text('Alert nearby help providers', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(child: Text(_locationName, style: const TextStyle(color: Colors.white60, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text('What\'s happening? *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: _symptomsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g., Chest pain since 2 hours, feeling dizzy, shortness of breath...',
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.urgent, width: 2)),
            ),
          ),

          const SizedBox(height: 24),
          const Text('How urgent is this?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: ['Low', 'Medium', 'High'].map((level) {
              final isSelected = _selectedRisk == level;
              final color = level == 'High' ? AppColors.urgent : (level == 'Medium' ? AppColors.warning : AppColors.success);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRisk = level),
                  child: Container(
                    margin: EdgeInsets.only(right: level != 'High' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
                    ),
                    child: Center(
                      child: Text(level, style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          if (!_isSending)
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _startCountdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.urgent, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('🚨  Send SOS Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            )
          else
            Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('$_countdown', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.urgent))),
                ),
                const SizedBox(height: 12),
                const Text('Sending in...', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: OutlinedButton(
                    onPressed: _cancelCountdown,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }


  Widget _buildActiveStatus() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sos_requests').doc(_activeRequestId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Status icon
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: status == 'accepted'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == 'accepted' ? Icons.check_circle : Icons.access_time_filled,
                  size: 60,
                  color: status == 'accepted' ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                status == 'accepted' ? 'Help is on the way! 🚑' : 'Looking for help nearby...',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Lato'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'accepted' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Status: ${status.toString().toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: status == 'accepted' ? AppColors.success : AppColors.warning)),
              ),


              if (status == 'accepted') ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.medical_services, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Your Helper', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 16),
                      _helperInfoRow(Icons.person, 'Name', data['helperName'] ?? 'Unknown'),
                      _helperInfoRow(Icons.phone, 'Phone', data['helperPhone'] ?? 'Not available'),
                      _helperInfoRow(Icons.work, 'Type', _formatHelperType(data['helperType'])),
                      _helperInfoRow(Icons.location_on, 'Area', data['helperAddress'] ?? 'Nearby'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              if (status != 'completed')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _cancelSOS,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(status == 'accepted' ? 'Cancel Request' : 'Cancel SOS'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _helperInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  String _formatHelperType(String? type) {
    if (type == null) return 'Helper';
    switch (type) {
      case 'ashaWorker': return 'ASHA Worker';
      case 'chemist': return 'Chemist';
      case 'localClinic': return 'Local Clinic';
      case 'volunteer': return 'Volunteer';
      default: return 'Helper';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        centerTitle: true,
        backgroundColor: _isSent ? AppColors.white : null,
      ),
      body: SafeArea(
        child: _isSent ? _buildActiveStatus() : _buildForm(),
      ),
    );
  }
}