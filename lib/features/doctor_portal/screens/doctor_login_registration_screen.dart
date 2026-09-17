import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../resources/app_colors.dart';
import '../../../resources/responsive.dart';
import '../controllers/doctor_portal_controller.dart';
import '../../../resources/app_routes.dart';

class DoctorLoginRegistrationScreen extends StatefulWidget {
  const DoctorLoginRegistrationScreen({super.key});

  @override
  State<DoctorLoginRegistrationScreen> createState() => _DoctorLoginRegistrationScreenState();
}

class _DoctorLoginRegistrationScreenState extends State<DoctorLoginRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _licenseController = TextEditingController();
  final _clinicController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _feeController = TextEditingController(text: '500');

  final List<String> _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Gynecologist',
    'Neurologist',
    'Psychiatrist',
    'ENT Specialist',
    'Dentist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _licenseController.dispose();
    _clinicController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorPortalController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Registration'),
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
              horizontal: context.wp(5).clamp(16.0, 24.0),
              vertical: context.hp(2).clamp(12.0, 24.0),
            ),
            children: [
              // Header Banner
              Container(
                padding: EdgeInsets.all(context.r(16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy, AppColors.navyLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join DocTalk Clinical Network',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Consult verified patients, manage clinic schedules, & write digital prescriptions.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.sp(11.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.hp(2.5)),

              _buildSectionTitle('Doctor Credentials'),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name (with Dr. prefix)',
                hint: 'e.g. Dr. Sameer Malhotra',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter doctor name' : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Official Email',
                hint: 'doctor@clinic.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Contact Number',
                hint: '+91 98765 43210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.length < 8) ? 'Valid phone number required' : null,
              ),
              _buildDropdownField(
                label: 'Primary Specialization',
                hint: 'Select Specialization',
                items: _specializations,
                onChanged: (val) {
                  if (val != null) _specializationController.text = val;
                },
              ),
              _buildTextField(
                controller: _qualificationController,
                label: 'Medical Qualifications',
                hint: 'e.g. MBBS, MD, MS, DNB',
                icon: Icons.school_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Qualification required' : null,
              ),
              _buildTextField(
                controller: _licenseController,
                label: 'Medical Registration / Council License No.',
                hint: 'e.g. MCI/2018/12345',
                icon: Icons.verified_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Registration number required' : null,
              ),

              SizedBox(height: context.hp(2)),
              _buildSectionTitle('Clinic & Consultation Details'),
              _buildTextField(
                controller: _clinicController,
                label: 'Hospital / Clinic Name',
                hint: 'e.g. Apollo Diagnostics & Care Clinic',
                icon: Icons.local_hospital_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Clinic name required' : null,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Clinic Address',
                hint: 'Street, Landmark, Sector',
                icon: Icons.place_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Address required' : null,
              ),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'e.g. Ambala / New Delhi',
                icon: Icons.location_city_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
              ),
              _buildTextField(
                controller: _feeController,
                label: 'Consultation Fee (₹)',
                hint: '500',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid fee' : null,
              ),

              SizedBox(height: context.hp(3)),

              // Submit Application Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await controller.registerDoctor(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                specialization: _specializationController.text.trim().isEmpty
                                    ? 'General Physician'
                                    : _specializationController.text.trim(),
                                qualification: _qualificationController.text.trim(),
                                licenseNumber: _licenseController.text.trim(),
                                clinicName: _clinicController.text.trim(),
                                address: _addressController.text.trim(),
                                city: _cityController.text.trim(),
                                consultationFee: double.tryParse(_feeController.text.trim()) ?? 500.0,
                              );

                              if (success) {
                                Get.offNamed(AppRoutes.doctorPending);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Submit Registration for Verification',
                            style: TextStyle(fontSize: context.sp(15), fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 20),
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryDark, size: 20),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
