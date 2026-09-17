class DoctorProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String qualification;
  final String licenseNumber;
  final String clinicName;
  final String address;
  final String city;
  final double consultationFee;
  final bool isVerified;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final bool emergencyMode;
  final int totalPatients;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double rating;
  final int reviewCount;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.qualification,
    required this.licenseNumber,
    required this.clinicName,
    required this.address,
    required this.city,
    required this.consultationFee,
    this.isVerified = false,
    this.verificationStatus = 'pending',
    this.emergencyMode = false,
    this.totalPatients = 0,
    this.monthlyEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.rating = 4.8,
    this.reviewCount = 0,
  });

  DoctorProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    String? qualification,
    String? licenseNumber,
    String? clinicName,
    String? address,
    String? city,
    double? consultationFee,
    bool? isVerified,
    String? verificationStatus,
    bool? emergencyMode,
    int? totalPatients,
    double? monthlyEarnings,
    double? weeklyEarnings,
    double? rating,
    int? reviewCount,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      city: city ?? this.city,
      consultationFee: consultationFee ?? this.consultationFee,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      emergencyMode: emergencyMode ?? this.emergencyMode,
      totalPatients: totalPatients ?? this.totalPatients,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'specialization': specialization,
        'qualification': qualification,
        'licenseNumber': licenseNumber,
        'clinicName': clinicName,
        'address': address,
        'city': city,
        'consultationFee': consultationFee,
        'isVerified': isVerified,
        'verificationStatus': verificationStatus,
        'emergencyMode': emergencyMode,
        'totalPatients': totalPatients,
        'monthlyEarnings': monthlyEarnings,
        'weeklyEarnings': weeklyEarnings,
        'rating': rating,
        'reviewCount': reviewCount,
      };

  factory DoctorProfile.fromMap(Map<String, dynamic> map, String docId) => DoctorProfile(
        id: docId,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        specialization: map['specialization'] ?? '',
        qualification: map['qualification'] ?? '',
        licenseNumber: map['licenseNumber'] ?? '',
        clinicName: map['clinicName'] ?? '',
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 500.0,
        isVerified: map['isVerified'] ?? false,
        verificationStatus: map['verificationStatus'] ?? 'pending',
        emergencyMode: map['emergencyMode'] ?? false,
        totalPatients: (map['totalPatients'] as num?)?.toInt() ?? 0,
        monthlyEarnings: (map['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
        weeklyEarnings: (map['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      );
}

class DoctorAppointmentItem {
  final String id;
  final String patientId;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String doctorId;
  final String date;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'rejected', 'completed'
  final String symptoms;
  final double consultationFee;
  final String? rejectionReason;

  DoctorAppointmentItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.symptoms,
    required this.consultationFee,
    this.rejectionReason,
  });

  DoctorAppointmentItem copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? doctorId,
    String? date,
    String? timeSlot,
    String? status,
    String? symptoms,
    double? consultationFee,
    String? rejectionReason,
  }) {
    return DoctorAppointmentItem(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      consultationFee: consultationFee ?? this.consultationFee,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'doctorId': doctorId,
        'date': date,
        'timeSlot': timeSlot,
        'status': status,
        'symptoms': symptoms,
        'consultationFee': consultationFee,
        'rejectionReason': rejectionReason,
      };

  factory DoctorAppointmentItem.fromMap(Map<String, dynamic> map, String docId) =>
      DoctorAppointmentItem(
        id: docId,
        patientId: map['patientId'] ?? '',
        patientName: map['patientName'] ?? 'Patient',
        patientAge: map['patientAge']?.toString() ?? '28',
        patientGender: map['patientGender'] ?? 'Other',
        doctorId: map['doctorId'] ?? '',
        date: map['date'] ?? '',
        timeSlot: map['timeSlot'] ?? '',
        status: map['status'] ?? 'pending',
        symptoms: map['symptoms'] ?? 'General Consultation',
        consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 500.0,
        rejectionReason: map['rejectionReason'],
      );
}

class MedicationItem {
  final String medicineName;
  final String dosage;
  final String frequency; // e.g. 1-0-1 (After Food)
  final String duration; // e.g. 5 Days
  final String instructions;

  MedicationItem({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = 'Take with warm water',
  });

  Map<String, dynamic> toMap() => {
        'medicineName': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'instructions': instructions,
      };

  factory MedicationItem.fromMap(Map<String, dynamic> map) => MedicationItem(
        medicineName: map['medicineName'] ?? '',
        dosage: map['dosage'] ?? '',
        frequency: map['frequency'] ?? '',
        duration: map['duration'] ?? '',
        instructions: map['instructions'] ?? '',
      );
}

class DoctorPrescription {
  final String id;
  final String appointmentId;
  final String patientName;
  final String doctorName;
  final String date;
  final String diagnosis;
  final List<MedicationItem> medications;
  final String advice;
  final String followUp;
  final String aiSummary;

  DoctorPrescription({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.medications,
    required this.advice,
    this.followUp = 'After 7 days if symptoms persist',
    this.aiSummary = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'appointmentId': appointmentId,
        'patientName': patientName,
        'doctorName': doctorName,
        'date': date,
        'diagnosis': diagnosis,
        'medications': medications.map((m) => m.toMap()).toList(),
        'advice': advice,
        'followUp': followUp,
        'aiSummary': aiSummary,
      };

  factory DoctorPrescription.fromMap(Map<String, dynamic> map, String docId) =>
      DoctorPrescription(
        id: docId,
        appointmentId: map['appointmentId'] ?? '',
        patientName: map['patientName'] ?? '',
        doctorName: map['doctorName'] ?? '',
        date: map['date'] ?? '',
        diagnosis: map['diagnosis'] ?? '',
        medications: (map['medications'] as List<dynamic>? ?? [])
            .map((m) => MedicationItem.fromMap(m as Map<String, dynamic>))
            .toList(),
        advice: map['advice'] ?? '',
        followUp: map['followUp'] ?? '',
        aiSummary: map['aiSummary'] ?? '',
      );
}

class DoctorSchedule {
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final String breakStartTime;
  final String breakEndTime;
  final bool isEmergencyAvailable;

  DoctorSchedule({
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.startTime = '09:00 AM',
    this.endTime = '08:00 PM',
    this.breakStartTime = '01:00 PM',
    this.breakEndTime = '02:00 PM',
    this.isEmergencyAvailable = false,
  });

  DoctorSchedule copyWith({
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    String? breakStartTime,
    String? breakEndTime,
    bool? isEmergencyAvailable,
  }) {
    return DoctorSchedule(
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      isEmergencyAvailable: isEmergencyAvailable ?? this.isEmergencyAvailable,
    );
  }

  Map<String, dynamic> toMap() => {
        'availableDays': availableDays,
        'startTime': startTime,
        'endTime': endTime,
        'breakStartTime': breakStartTime,
        'breakEndTime': breakEndTime,
        'isEmergencyAvailable': isEmergencyAvailable,
      };

  factory DoctorSchedule.fromMap(Map<String, dynamic> map) => DoctorSchedule(
        availableDays: List<String>.from(map['availableDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
        startTime: map['startTime'] ?? '09:00 AM',
        endTime: map['endTime'] ?? '08:00 PM',
        breakStartTime: map['breakStartTime'] ?? '01:00 PM',
        breakEndTime: map['breakEndTime'] ?? '02:00 PM',
        isEmergencyAvailable: map['isEmergencyAvailable'] ?? false,
      );
}
