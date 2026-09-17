import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorSlotModel {
  final String doctorId;
  final List<String> availableDays; // e.g. ['Monday', 'Tuesday', ...]
  final String startTime; // e.g. "09:00 AM"
  final String endTime; // e.g. "05:00 PM"
  final int slotDurationMinutes; // e.g. 30
  final String breakStartTime; // e.g. "01:00 PM"
  final String breakEndTime; // e.g. "02:00 PM"
  final List<String> holidays; // e.g. ['2026-10-02']
  final DateTime updatedAt;

  DoctorSlotModel({
    required this.doctorId,
    this.availableDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    this.startTime = '09:00 AM',
    this.endTime = '05:00 PM',
    this.slotDurationMinutes = 30,
    this.breakStartTime = '01:00 PM',
    this.breakEndTime = '02:00 PM',
    this.holidays = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  DoctorSlotModel copyWith({
    String? doctorId,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    int? slotDurationMinutes,
    String? breakStartTime,
    String? breakEndTime,
    List<String>? holidays,
    DateTime? updatedAt,
  }) {
    return DoctorSlotModel(
      doctorId: doctorId ?? this.doctorId,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      holidays: holidays ?? this.holidays,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'availableDays': availableDays,
    'startTime': startTime,
    'endTime': endTime,
    'slotDurationMinutes': slotDurationMinutes,
    'breakStartTime': breakStartTime,
    'breakEndTime': breakEndTime,
    'holidays': holidays,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory DoctorSlotModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime updated;
    final rawUpdated = map['updatedAt'];
    if (rawUpdated is Timestamp) {
      updated = rawUpdated.toDate();
    } else {
      updated = DateTime.now();
    }

    return DoctorSlotModel(
      doctorId: docId,
      availableDays: List<String>.from(map['availableDays'] ?? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']),
      startTime: map['startTime'] ?? '09:00 AM',
      endTime: map['endTime'] ?? '05:00 PM',
      slotDurationMinutes: (map['slotDurationMinutes'] as num?)?.toInt() ?? 30,
      breakStartTime: map['breakStartTime'] ?? '01:00 PM',
      breakEndTime: map['breakEndTime'] ?? '02:00 PM',
      holidays: List<String>.from(map['holidays'] ?? []),
      updatedAt: updated,
    );
  }

  factory DoctorSlotModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return DoctorSlotModel.fromMap(doc.data() ?? {}, doc.id);
  }

  /// Automatically generates available time slot strings for a given date
  List<String> generateTimeSlotsForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (holidays.contains(dateStr)) {
      return [];
    }

    final dayName = DateFormat('EEEE').format(date); // e.g. 'Monday'
    final isAvailableDay = availableDays.any((d) => d.toLowerCase() == dayName.toLowerCase());
    if (!isAvailableDay) {
      return [];
    }

    try {
      final start = _parseTimeString(startTime, date);
      final end = _parseTimeString(endTime, date);
      final breakStart = _parseTimeString(breakStartTime, date);
      final breakEnd = _parseTimeString(breakEndTime, date);

      if (start == null || end == null) return _defaultSlots();

      final List<String> slots = [];
      DateTime curr = start;

      while (curr.isBefore(end)) {
        final slotEnd = curr.add(Duration(minutes: slotDurationMinutes));
        if (slotEnd.isAfter(end)) break;

        // Skip slot if it falls inside the break window
        bool isInBreak = false;
        if (breakStart != null && breakEnd != null) {
          if ((curr.isAfter(breakStart) || curr.isAtSameMomentAs(breakStart)) && curr.isBefore(breakEnd)) {
            isInBreak = true;
          }
        }

        if (!isInBreak) {
          slots.add(DateFormat('hh:mm a').format(curr));
        }

        curr = slotEnd;
      }

      return slots.isNotEmpty ? slots : _defaultSlots();
    } catch (_) {
      return _defaultSlots();
    }
  }

  static DateTime? _parseTimeString(String timeStr, DateTime baseDate) {
    try {
      final clean = timeStr.trim();
      final format = DateFormat('hh:mm a');
      final dt = format.parse(clean);
      return DateTime(baseDate.year, baseDate.month, baseDate.day, dt.hour, dt.minute);
    } catch (_) {
      try {
        final format24 = DateFormat('HH:mm');
        final dt = format24.parse(timeStr.trim());
        return DateTime(baseDate.year, baseDate.month, baseDate.day, dt.hour, dt.minute);
      } catch (_) {
        return null;
      }
    }
  }

  static List<String> _defaultSlots() {
    return ['09:00 AM', '10:00 AM', '11:00 AM', '02:30 PM', '04:00 PM', '05:30 PM'];
  }
}
