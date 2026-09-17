import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_portal_models.dart';

class DoctorPortalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local fallback cache for offline resilience and demonstration
  static DoctorProfile? _localDoctorProfile;
  static final List<DoctorAppointmentItem> _localAppointments = [
    DoctorAppointmentItem(
      id: 'apt_101',
      patientId: 'pat_01',
      patientName: 'Aarav Sharma',
      patientAge: '32',
      patientGender: 'Male',
      doctorId: 'doc_current',
      date: 'Today',
      timeSlot: '10:30 AM',
      status: 'pending',
      symptoms: 'Persistent dry cough and mild fever for 4 days.',
      consultationFee: 500.0,
    ),
    DoctorAppointmentItem(
      id: 'apt_102',
      patientId: 'pat_02',
      patientName: 'Priya Mehra',
      patientAge: '27',
      patientGender: 'Female',
      doctorId: 'doc_current',
      date: 'Today',
      timeSlot: '11:15 AM',
      status: 'confirmed',
      symptoms: 'Skin rash with redness on forearms after allergy.',
      consultationFee: 500.0,
    ),
    DoctorAppointmentItem(
      id: 'apt_103',
      patientId: 'pat_03',
      patientName: 'Karan Patel',
      patientAge: '45',
      patientGender: 'Male',
      doctorId: 'doc_current',
      date: 'Today',
      timeSlot: '02:30 PM',
      status: 'confirmed',
      symptoms: 'Hypertension checkup and routine blood pressure review.',
      consultationFee: 500.0,
    ),
    DoctorAppointmentItem(
      id: 'apt_104',
      patientId: 'pat_04',
      patientName: 'Ananya Gupta',
      patientAge: '8',
      patientGender: 'Female',
      doctorId: 'doc_current',
      date: 'Yesterday',
      timeSlot: '04:00 PM',
      status: 'completed',
      symptoms: 'Pediatric seasonal flu and throat pain.',
      consultationFee: 500.0,
    ),
  ];

  static final List<DoctorPrescription> _localPrescriptions = [];

  String? get currentUserId => _auth.currentUser?.uid;

  /// Register or update doctor profile in Firestore
  Future<void> registerDoctor(DoctorProfile profile) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) {
      throw FirebaseAuthException(
        code: 'NOT_AUTHENTICATED',
        message: 'You must be signed in to register as a doctor.',
      );
    }

    final updatedProfile = profile.copyWith(id: uid);
    _localDoctorProfile = updatedProfile;

    final batch = _firestore.batch();
    final docRef = _firestore.collection('doctors').doc(uid);
    final userRef = _firestore.collection('users').doc(uid);

    batch.set(docRef, updatedProfile.toMap(), SetOptions(merge: true));
    batch.set(userRef, {'role': 'doctor'}, SetOptions(merge: true));

    await batch.commit();
  }

  /// Get current doctor profile
  Future<DoctorProfile?> getDoctorProfile() async {
    if (_localDoctorProfile != null) return _localDoctorProfile;

    try {
      final uid = currentUserId;
      if (uid != null) {
        final doc = await _firestore.collection('doctors').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          _localDoctorProfile = DoctorProfile.fromMap(doc.data()!, doc.id);
          return _localDoctorProfile;
        }
      }
    } catch (_) {}

    // Default active profile for instant demonstration
    _localDoctorProfile = DoctorProfile(
      id: currentUserId ?? 'doc_current',
      name: 'Dr. Sameer Malhotra',
      email: _auth.currentUser?.email ?? 'dr.sameer@doctalk.com',
      phone: '+91 98765 43210',
      specialization: 'General Physician & Cardiologist',
      qualification: 'MBBS, MD (Internal Medicine)',
      licenseNumber: 'MCI/2018/78291',
      clinicName: 'Malhotra Health & Diagnostic Clinic',
      address: 'Near Civil Hospital, Model Town',
      city: 'Ambala',
      consultationFee: 500.0,
      isVerified: true,
      verificationStatus: 'approved',
      emergencyMode: false,
      totalPatients: 148,
      monthlyEarnings: 74000.0,
      weeklyEarnings: 18500.0,
      rating: 4.9,
      reviewCount: 64,
    );
    return _localDoctorProfile;
  }

  /// Fetch all appointments for doctor
  Future<List<DoctorAppointmentItem>> getDoctorAppointments() async {
    try {
      final uid = currentUserId ?? 'doc_current';
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DoctorAppointmentItem.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (_) {}

    return List.from(_localAppointments);
  }

  /// Update appointment status (accept / reject / complete)
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus, {String? reason}) async {
    final index = _localAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _localAppointments[index] = _localAppointments[index].copyWith(
        status: newStatus,
        rejectionReason: reason,
      );
    }

    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
        if (reason != null) 'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Create and save digital prescription
  Future<void> savePrescription(DoctorPrescription prescription) async {
    _localPrescriptions.add(prescription);

    // Also mark appointment as completed
    await updateAppointmentStatus(prescription.appointmentId, 'completed');

    try {
      await _firestore.collection('prescriptions').doc(prescription.id).set(prescription.toMap());
    } catch (_) {}
  }

  /// Toggle doctor emergency mode
  Future<void> toggleEmergencyMode(bool isEmergency) async {
    if (_localDoctorProfile != null) {
      _localDoctorProfile = _localDoctorProfile!.copyWith(emergencyMode: isEmergency);
    }
    try {
      final uid = currentUserId ?? 'doc_current';
      await _firestore.collection('doctors').doc(uid).update({'emergencyMode': isEmergency});
    } catch (_) {}
  }
}
