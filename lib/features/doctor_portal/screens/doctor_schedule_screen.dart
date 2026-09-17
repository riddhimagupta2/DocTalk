import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../controllers/doctor_portal_controller.dart';
import '../models/doctor_portal_models.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _selectedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String _startTime = '09:00 AM';
  String _endTime = '08:00 PM';
  String _breakStart = '01:00 PM';
  String _breakEnd = '02:00 PM';

  @override
  void initState() {
    super.initState();
    final current = Get.find<DoctorPortalController>().schedule.value;
    _selectedDays.clear();
    _selectedDays.addAll(current.availableDays);
    _startTime = current.startTime;
    _endTime = current.endTime;
    _breakStart = current.breakStartTime;
    _breakEnd = current.breakEndTime;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorPortalController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinic & Consultation Hours'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(16.0, 24.0),
            vertical: context.hp(2).clamp(14.0, 24.0),
          ),
          children: [
            // Available Days Card
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Working Days',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _daysOfWeek.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: AppColors.background,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              if (_selectedDays.length > 1) {
                                _selectedDays.remove(day);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.hp(2)),

            // Consultation Timing Card
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Clinic Hours',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerTile(
                          context,
                          label: 'Opens At',
                          time: _startTime,
                          onTap: () async {
                            final picked = await _pickTime(context, _startTime);
                            if (picked != null) setState(() => _startTime = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerTile(
                          context,
                          label: 'Closes At',
                          time: _endTime,
                          onTap: () async {
                            final picked = await _pickTime(context, _endTime);
                            if (picked != null) setState(() => _endTime = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: context.hp(2)),

            // Break Timing Card
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.coffee_rounded, color: Color(0xFFF59E0B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Break / Lunch Interval',
                        style: TextStyle(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerTile(
                          context,
                          label: 'Break Start',
                          time: _breakStart,
                          onTap: () async {
                            final picked = await _pickTime(context, _breakStart);
                            if (picked != null) setState(() => _breakStart = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerTile(
                          context,
                          label: 'Break End',
                          time: _breakEnd,
                          onTap: () async {
                            final picked = await _pickTime(context, _breakEnd);
                            if (picked != null) setState(() => _breakEnd = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: context.hp(4)),

            ElevatedButton(
              onPressed: () {
                final newSchedule = DoctorSchedule(
                  availableDays: _selectedDays,
                  startTime: _startTime,
                  endTime: _endTime,
                  breakStartTime: _breakStart,
                  breakEndTime: _breakEnd,
                );
                controller.updateSchedule(newSchedule);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Save Consultation Schedule',
                style: TextStyle(fontSize: context.sp(15), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    BuildContext context, {
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(11),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final TimeOfDay initial = _parseTimeOfDay(current);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
    return null;
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }
}
