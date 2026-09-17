import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/appointment_model.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'DocTalk Admin Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: context.sp(17), fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(context.r(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analytics Overview Cards
              Text(
                'System Analytics Overview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(15), fontFamily: 'Poppins'),
              ),
              SizedBox(height: context.hp(1.2)),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Doctors',
                      value: '${controller.totalDoctorsCount}',
                      icon: Icons.medical_services_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Verified',
                      value: '${controller.verifiedCount}',
                      icon: Icons.verified_rounded,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Pending Applications',
                      value: '${controller.pendingCount}',
                      icon: Icons.hourglass_top_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Appointments',
                      value: '${controller.totalAppointmentsCount}',
                      icon: Icons.event_available_rounded,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.hp(2.5)),

              // Doctor Applications Verification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor Verification Applications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(15), fontFamily: 'Poppins'),
                  ),
                  Chip(
                    label: Text('${controller.pendingCount} Pending', style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (controller.allDoctors.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No doctor accounts registered yet.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.allDoctors.length,
                  itemBuilder: (context, index) {
                    final doc = controller.allDoctors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: doc.isDocTalkVerified ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                          child: Icon(doc.isDocTalkVerified ? Icons.verified_rounded : Icons.person_outline_rounded,
                              color: doc.isDocTalkVerified ? Colors.green : Colors.orange),
                        ),
                        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        subtitle: Text('${doc.specialization} • ${doc.hospitalOrClinicName}\nPhone: ${doc.phone}'),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (!doc.isDocTalkVerified)
                              ElevatedButton(
                                onPressed: () => controller.verifyDoctor(doc.placeId),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text('Verify'),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.block_rounded, color: Colors.red),
                                onPressed: () => controller.blockDoctor(doc.placeId),
                                tooltip: 'Block Doctor',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: context.hp(2.5)),

              // System Appointments Overview
              Text(
                'Recent System Appointments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(15), fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 8),
              if (controller.allAppointments.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('No appointments booked in system yet.')))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.allAppointments.length,
                  itemBuilder: (context, index) {
                    final apt = controller.allAppointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${apt.patientName} ➔ Dr. ${apt.doctorName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        subtitle: Text('Date: ${apt.date} at ${apt.time} | Status: ${apt.status.value}'),
                        trailing: Text('₹${apt.consultationFee.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.r(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: context.r(24)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(20), color: color, fontFamily: 'Poppins')),
          Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(12), fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
