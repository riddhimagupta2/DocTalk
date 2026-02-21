import 'doctor_model.dart';

enum AppointmentStatus { confirmed, pending, cancelled, completed }

class AppointmentModel {
  final String id;
  final DoctorModel doctor;
  final DateTime date;
  final String timeSlot;
  final String patientName;
  final String patientPhone;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.patientName,
    required this.patientPhone,
    required this.reason,
    this.status = AppointmentStatus.confirmed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorName': doctor.name,
    'doctorSpecialization': doctor.specialization,
    'doctorAddress': doctor.address,
    'doctorPhone': doctor.phone,
    'consultationFee': doctor.consultationFee,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'reason': reason,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
}