import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/patient_appointment_controller.dart';
import '../../models/appointment_model.dart';
import '../../resources/app_colors.dart';
import '../../resources/responsive.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientAppointmentController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: context.r(18)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'My Appointments',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: context.sp(16),
              fontFamily: 'Poppins',
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _AppointmentList(
                appointments: controller.upcomingAppointments,
                onCancel: (apt) => _showCancelDialog(context, controller, apt),
                onReschedule: (apt) => _showRescheduleDialog(context, controller, apt),
                onReminder: (apt) => controller.setAppointmentReminder(apt),
              ),
              _AppointmentList(
                appointments: controller.completedAppointments,
              ),
              _AppointmentList(
                appointments: controller.cancelledAppointments,
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, PatientAppointmentController controller, AppointmentModel appointment) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Appointment', style: TextStyle(fontSize: context.sp(15), fontFamily: 'Poppins')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel your appointment with Dr. ${appointment.doctorName}?',
                style: TextStyle(fontSize: context.sp(13), fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Keep Appointment')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(appointment.appointmentId, reasonCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(
      BuildContext context, PatientAppointmentController controller, AppointmentModel appointment) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedTime = '10:00 AM';

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Reschedule Appointment', style: TextStyle(fontSize: context.sp(15), fontFamily: 'Poppins')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: Text(DateFormat('EEEE, d MMM yyyy').format(selectedDate)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedTime,
                items: const [
                  DropdownMenuItem(value: '09:00 AM', child: Text('09:00 AM')),
                  DropdownMenuItem(value: '10:00 AM', child: Text('10:00 AM')),
                  DropdownMenuItem(value: '11:30 AM', child: Text('11:30 AM')),
                  DropdownMenuItem(value: '02:00 PM', child: Text('02:00 PM')),
                  DropdownMenuItem(value: '04:30 PM', child: Text('04:30 PM')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedTime = val);
                },
                decoration: const InputDecoration(labelText: 'Select New Slot', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                final formatted = DateFormat('yyyy-MM-dd').format(selectedDate);
                controller.rescheduleAppointment(
                  appointmentId: appointment.appointmentId,
                  newDate: formatted,
                  newTime: selectedTime,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Submit Reschedule', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final Function(AppointmentModel)? onCancel;
  final Function(AppointmentModel)? onReschedule;
  final Function(AppointmentModel)? onReminder;

  const _AppointmentList({
    required this.appointments,
    this.onCancel,
    this.onReschedule,
    this.onReminder,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: context.r(48), color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('No appointments found', style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(14))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(context.r(14)),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(context.r(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      apt.doctorName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(14.5),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    _StatusBadge(status: apt.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  apt.doctorSpecialization.isNotEmpty ? apt.doctorSpecialization : 'General Physician',
                  style: TextStyle(color: AppColors.primary, fontSize: context.sp(12.5), fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: context.r(16), color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${apt.date} at ${apt.time}',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: context.sp(12.5), fontFamily: 'Poppins')),
                  ],
                ),
                if (apt.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Reason: ${apt.symptoms}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(12), fontFamily: 'Poppins')),
                ],
                if (apt.rejectionReason != null && apt.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Note: ${apt.rejectionReason}',
                      style: TextStyle(color: Colors.redAccent, fontSize: context.sp(12), fontFamily: 'Poppins')),
                ],
                if (onCancel != null || onReschedule != null) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onReminder != null)
                        IconButton(
                          icon: const Icon(Icons.alarm_add_rounded, color: AppColors.primary),
                          onPressed: () => onReminder!(apt),
                          tooltip: 'Set Reminder',
                        ),
                      if (onReschedule != null)
                        TextButton.icon(
                          onPressed: () => onReschedule!(apt),
                          icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                          label: const Text('Reschedule'),
                        ),
                      if (onCancel != null)
                        TextButton.icon(
                          onPressed: () => onCancel!(apt),
                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                          label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case AppointmentStatus.accepted:
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green;
        break;
      case AppointmentStatus.pending:
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange;
        break;
      case AppointmentStatus.rejected:
      case AppointmentStatus.cancelled:
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red;
        break;
      case AppointmentStatus.completed:
        bg = Colors.teal.withValues(alpha: 0.15);
        fg = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.value,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Poppins'),
      ),
    );
  }
}
