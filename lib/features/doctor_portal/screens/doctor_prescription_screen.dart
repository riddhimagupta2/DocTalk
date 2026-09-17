import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../controllers/doctor_appointment_controller.dart';
import '../controllers/doctor_portal_controller.dart';
import '../models/doctor_portal_models.dart';
import '../../../models/appointment_model.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  const DoctorPrescriptionScreen({super.key});

  @override
  State<DoctorPrescriptionScreen> createState() => _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController(text: 'Adequate hydration, warm saline gargle, rest for 48 hours.');
  final _followUpController = TextEditingController(text: 'Follow-up after 5 days if symptoms persist.');

  final List<MedicationItem> _medications = [
    MedicationItem(
      medicineName: 'Tab. Paracetamol',
      dosage: '650 mg',
      frequency: '1-0-1 (After Food)',
      duration: '3 Days',
      instructions: 'Take in case of body pain or fever > 99.5°F',
    ),
    MedicationItem(
      medicineName: 'Tab. Levocetirizine',
      dosage: '5 mg',
      frequency: '0-0-1 (Night)',
      duration: '5 Days',
      instructions: 'May cause mild sedation',
    ),
  ];

  String _appointmentId = 'apt_walkin';
  String _patientName = 'Walk-in Consultation';
  String _patientAge = '30';
  String _patientGender = 'Male';
  String _symptoms = '';

  @override
  void initState() {
    super.initState();
    final rawArg = Get.arguments;
    if (rawArg is AppointmentModel) {
      _appointmentId = rawArg.appointmentId;
      _patientName = rawArg.patientName;
      _patientAge = rawArg.patientAge;
      _patientGender = rawArg.patientGender;
      _symptoms = rawArg.symptoms;
    } else if (rawArg is DoctorAppointmentItem) {
      _appointmentId = rawArg.id;
      _patientName = rawArg.patientName;
      _patientAge = rawArg.patientAge.toString();
      _patientGender = rawArg.patientGender;
      _symptoms = rawArg.symptoms;
    }
    if (_symptoms.isNotEmpty) {
      _diagnosisController.text = 'Clinical evaluation for $_symptoms';
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _adviceController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentCtrl = Get.find<DoctorAppointmentController>();
    final portalCtrl = Get.find<DoctorPortalController>();
    final docName = portalCtrl.profile.value?.name ?? 'Dr. Sameer Malhotra';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Digital Prescription (Rx)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(4).clamp(16.0, 24.0),
              vertical: context.hp(2).clamp(12.0, 20.0),
            ),
            children: [
              // Patient Banner
              Container(
                padding: EdgeInsets.all(context.r(14)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        _patientName.isNotEmpty ? _patientName[0] : 'P',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _patientName,
                            style: TextStyle(
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            '$_patientAge yrs • $_patientGender • Today',
                            style: TextStyle(
                              fontSize: context.sp(12),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Prescribing: $docName',
                        style: TextStyle(
                          fontSize: context.sp(10.5),
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2)),

              // Diagnosis Section
              _buildSectionTitle('Clinical Diagnosis & Impression'),
              TextFormField(
                controller: _diagnosisController,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter diagnosis' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Acute Upper Respiratory Tract Infection',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              SizedBox(height: context.hp(2.5)),

              // Medications Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Rx - Prescribed Medications (${_medications.length})'),
                  TextButton.icon(
                    onPressed: () => _showAddMedicineDialog(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('Add Medicine'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),

              if (_medications.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('No medications added yet. Tap "Add Medicine".'),
                  ),
                )
              else
                ..._medications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final med = entry.value;
                  return _buildMedicationTile(context, index, med);
                }),

              SizedBox(height: context.hp(2)),

              // Advice Section
              _buildSectionTitle('Dietary & Lifestyle Advice'),
              TextFormField(
                controller: _adviceController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Special instructions, precautions, lifestyle advice',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              SizedBox(height: context.hp(2)),

              // Follow-up Section
              _buildSectionTitle('Follow-up Review'),
              TextFormField(
                controller: _followUpController,
                decoration: InputDecoration(
                  hintText: 'e.g. Return after 5 days if fever persists',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),

              SizedBox(height: context.hp(3.5)),

              // Submit Rx Button
              Obx(() => ElevatedButton.icon(
                    onPressed: appointmentCtrl.isSubmitting.value
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_medications.isEmpty) {
                                Get.snackbar('Error', 'Please add at least one medication to prescribe');
                                return;
                              }

                              final prescription = DoctorPrescription(
                                id: 'rx_${DateTime.now().millisecondsSinceEpoch}',
                                appointmentId: _appointmentId,
                                patientName: _patientName,
                                doctorName: docName,
                                date: 'Today',
                                diagnosis: _diagnosisController.text.trim(),
                                medications: _medications,
                                advice: _adviceController.text.trim(),
                                followUp: _followUpController.text.trim(),
                              );

                              final success = await appointmentCtrl.savePrescription(prescription);
                              if (success) {
                                Get.back();
                              }
                            }
                          },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: appointmentCtrl.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Sign & Issue Digital Prescription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  )),

              SizedBox(height: context.hp(2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildMedicationTile(BuildContext context, int index, MedicationItem med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(context.r(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${med.medicineName} (${med.dosage})',
                  style: TextStyle(
                    fontSize: context.sp(13.5),
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Schedule: ${med.frequency} • ${med.duration}',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (med.instructions.isNotEmpty)
                  Text(
                    'Note: ${med.instructions}',
                    style: TextStyle(
                      fontSize: context.sp(11),
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() {
                _medications.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '500 mg');
    final freqCtrl = TextEditingController(text: '1-0-1 (After Food)');
    final durCtrl = TextEditingController(text: '5 Days');
    final noteCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  hintText: 'e.g. Tab. Amoxicillin',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(labelText: 'Dosage', hintText: 'e.g. 500 mg / 10 ml'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency', hintText: 'e.g. 1-0-1 / Once daily'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durCtrl,
                decoration: const InputDecoration(labelText: 'Duration', hintText: 'e.g. 5 Days / 1 Week'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Special Instruction', hintText: 'After meals with water'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _medications.add(MedicationItem(
                    medicineName: nameCtrl.text.trim(),
                    dosage: dosageCtrl.text.trim(),
                    frequency: freqCtrl.text.trim(),
                    duration: durCtrl.text.trim(),
                    instructions: noteCtrl.text.trim(),
                  ));
                });
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
