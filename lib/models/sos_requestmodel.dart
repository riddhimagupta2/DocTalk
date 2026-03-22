import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, completed, cancelled }

class SOSRequest {
  final String id;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final double latitude;
  final double longitude;
  final String? symptoms;
  final String? riskLevel;
  final RequestStatus status;
  final String? helperId;
  final String? helperName;
  final DateTime timestamp;
  final String? notes;

  SOSRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.latitude,
    required this.longitude,
    this.symptoms,
    this.riskLevel,
    this.status = RequestStatus.pending,
    this.helperId,
    this.helperName,
    required this.timestamp,
    this.notes,
  });

  factory SOSRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SOSRequest(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown',
      patientPhone: data['patientPhone'],
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      symptoms: data['symptoms'],
      riskLevel: data['riskLevel'],
      status: _parseStatus(data['status']),
      helperId: data['helperId'],
      helperName: data['helperName'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'latitude': latitude,
      'longitude': longitude,
      'symptoms': symptoms,
      'riskLevel': riskLevel,
      'status': status.name,
      'helperId': helperId,
      'helperName': helperName,
      'timestamp': Timestamp.fromDate(timestamp),
      'notes': notes,
    };
  }

  static RequestStatus _parseStatus(String? value) {
    if (value == null) return RequestStatus.pending;
    return RequestStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => RequestStatus.pending,
    );
  }
}