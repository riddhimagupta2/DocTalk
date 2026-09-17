import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_model.dart';

enum AppointmentStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get value {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.accepted:
        return 'Accepted';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static AppointmentStatus fromString(String val) {
    switch (val.trim().toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return AppointmentStatus.accepted;
      case 'rejected':
        return AppointmentStatus.rejected;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
      case 'canceled':
        return AppointmentStatus.cancelled;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }
}

class AppointmentModel {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorAddress;
  final String doctorPhone;
  final String patientName;
  final String patientPhone;
  final String date; // YYYY-MM-DD
  final String time; // e.g. "10:30 AM"
  final AppointmentStatus status;
  final String symptoms;
  final double consultationFee;
  final String? rejectionReason;
  final String? rescheduleDate;
  final String? rescheduleTime;
  final DateTime createdAt;
  final DoctorModel? doctorObj;

  AppointmentModel({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialization = '',
    this.doctorAddress = '',
    this.doctorPhone = '',
    required this.patientName,
    this.patientPhone = '',
    required this.date,
    required this.time,
    this.status = AppointmentStatus.pending,
    this.symptoms = '',
    this.consultationFee = 0.0,
    this.rejectionReason,
    this.rescheduleDate,
    this.rescheduleTime,
    DateTime? createdAt,
    this.doctorObj,
  }) : createdAt = createdAt ?? DateTime.now();

  // Backward compatibility getters
  String get id => appointmentId;
  String get timeSlot => time;
  String get reason => symptoms;
  String get patientAge => '32';
  String get patientGender => 'Female';
  String get statusString => status.value.toLowerCase();
  DoctorModel get doctor => doctorObj ?? DoctorModel(
    placeId: doctorId,
    name: doctorName,
    specialization: doctorSpecialization,
    address: doctorAddress,
    phone: doctorPhone,
    latitude: 0,
    longitude: 0,
    consultationFee: consultationFee,
    isDocTalkVerified: true,
  );

  DateTime get dateTime {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}
    return createdAt;
  }

  AppointmentModel copyWith({
    String? appointmentId,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialization,
    String? doctorAddress,
    String? doctorPhone,
    String? patientName,
    String? patientPhone,
    String? date,
    String? time,
    AppointmentStatus? status,
    String? symptoms,
    double? consultationFee,
    String? rejectionReason,
    String? rescheduleDate,
    String? rescheduleTime,
    DateTime? createdAt,
    DoctorModel? doctorObj,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
      doctorAddress: doctorAddress ?? this.doctorAddress,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      consultationFee: consultationFee ?? this.consultationFee,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rescheduleDate: rescheduleDate ?? this.rescheduleDate,
      rescheduleTime: rescheduleTime ?? this.rescheduleTime,
      createdAt: createdAt ?? this.createdAt,
      doctorObj: doctorObj ?? this.doctorObj,
    );
  }

  Map<String, dynamic> toMap() => {
    'appointmentId': appointmentId,
    'patientId': patientId,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'doctorSpecialization': doctorSpecialization,
    'doctorAddress': doctorAddress,
    'doctorPhone': doctorPhone,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'date': date,
    'time': time,
    'status': status.value,
    'symptoms': symptoms,
    'consultationFee': consultationFee,
    'rejectionReason': rejectionReason,
    'rescheduleDate': rescheduleDate,
    'rescheduleTime': rescheduleTime,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppointmentModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime created;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return AppointmentModel(
      appointmentId: docId ?? map['appointmentId'] ?? map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? 'Doctor',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      doctorAddress: map['doctorAddress'] ?? '',
      doctorPhone: map['doctorPhone'] ?? '',
      patientName: map['patientName'] ?? 'Patient',
      patientPhone: map['patientPhone'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? map['timeSlot'] ?? '',
      status: AppointmentStatusExtension.fromString(map['status'] ?? 'Pending'),
      symptoms: map['symptoms'] ?? map['reason'] ?? '',
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 0.0,
      rejectionReason: map['rejectionReason'],
      rescheduleDate: map['rescheduleDate'],
      rescheduleTime: map['rescheduleTime'],
      createdAt: created,
    );
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppointmentModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toJson() => toMap();
}
