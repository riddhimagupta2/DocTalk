import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../resources/AppTheme.dart';
import '../../widgets/CustomWidgets/custom_button.dart';
import '../../widgets/CustomWidgets/custom_textfields.dart';

class HelperSignupScreen extends StatefulWidget {
  const HelperSignupScreen({super.key});

  @override
  State<HelperSignupScreen> createState() => _HelperSignupScreenState();
}

class _HelperSignupScreenState extends State<HelperSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;
  HelperType _selectedType = HelperType.volunteer;
  bool _detectingLocation = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        Get.snackbar(
            'Missing Info', 'Please fill all fields before continuing.',
            backgroundColor: AppColors.warning, colorText: Colors.white);
        return;
      }
      if (_passwordController.text != _confirmController.text) {
        Get.snackbar('Password Mismatch', 'Passwords do not match.',
            backgroundColor: AppColors.error, colorText: Colors.white);
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _autoDetectLocation() async {
    setState(() => _detectingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        Get.snackbar('Permission Denied', 'Please allow location access.',
            backgroundColor: AppColors.warning, colorText: Colors.white);
        setState(() => _detectingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      _latController.text = pos.latitude.toStringAsFixed(6);
      _lngController.text = pos.longitude.toStringAsFixed(6);

      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          _addressController.text =
              '${p.subLocality ?? ''} ${p.locality ?? ''}, ${p.administrativeArea ?? ''}'
                  .trim();
        }
      } catch (_) {}

      Get.snackbar(
          'Location Detected! 📍',
          _addressController.text.isEmpty
              ? 'Coordinates set'
              : _addressController.text,
          backgroundColor: AppColors.success,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Could not detect location.',
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      setState(() => _detectingLocation = false);
    }
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _authController.signUpHelper(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        helperType: _selectedType,
        latitude: double.tryParse(_latController.text) ?? 0.0,
        longitude: double.tryParse(_lngController.text) ?? 0.0,
        address: _addressController.text,
        description: _descController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        if (_currentStep > 0) {
                          _prevStep();
                        } else {
                          Get.back();
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Progress
                    Row(
                      children: List.generate(
                          3,
                          (i) => Expanded(
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: i <= _currentStep
                                        ? AppColors.primary
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              )),
                    ),
                    const SizedBox(height: 28),

                    if (_currentStep == 0) _buildStep1(),
                    if (_currentStep == 1) _buildStep2(),
                    if (_currentStep == 2) _buildStep3(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Join as a\nHelp Provider 🤝',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
              letterSpacing: -1,
              fontFamily: 'Lato'),
        ),
        const SizedBox(height: 10),
        const Text('Your basic information',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 28),
        CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Dr. Priya Sharma',
            prefixIcon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null),
        const SizedBox(height: 14),
        CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !GetUtils.isEmail(v))
                ? 'Valid email required'
                : null),
        const SizedBox(height: 14),
        CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+91 9876543210',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Phone is required' : null),
        const SizedBox(height: 14),
        CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword)),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null),
        const SizedBox(height: 14),
        CustomTextField(
            controller: _confirmController,
            label: 'Confirm Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
                icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm)),
            validator: (v) => (v != _passwordController.text)
                ? 'Passwords don\'t match'
                : null),
        const SizedBox(height: 28),
        CustomButton(label: 'Continue →', onPressed: _nextStep),
      ],
    );
  }

  // ── STEP 2: Helper Type & Location ──
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Role &\nLocation 📍',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
              letterSpacing: -1,
              fontFamily: 'Lato'),
        ),
        const SizedBox(height: 10),
        const Text('Tell us how and where you help',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 28),

        const Text('Select your role:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: HelperType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(_helperTypeLabel(type)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              backgroundColor: AppColors.white,
              side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border),
              onSelected: (_) => setState(() => _selectedType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        CustomTextField(
            controller: _addressController,
            label: 'Address / Area',
            hint: 'Rajpur Road, Dehradun',
            prefixIcon: Icons.location_on_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Address is required' : null),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _detectingLocation ? null : _autoDetectLocation,
            icon: _detectingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : const Icon(Icons.my_location, size: 18),
            label: Text(_detectingLocation
                ? 'Detecting...'
                : 'Auto-Detect My Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
                child: CustomTextField(
                    controller: _latController,
                    label: 'Latitude',
                    hint: '30.3165',
                    prefixIcon: Icons.gps_fixed,
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: CustomTextField(
                    controller: _lngController,
                    label: 'Longitude',
                    hint: '78.0322',
                    prefixIcon: Icons.gps_fixed,
                    keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 28),
        CustomButton(label: 'Continue →', onPressed: _nextStep),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Almost done! ✅',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
              letterSpacing: -1,
              fontFamily: 'Lato'),
        ),
        const SizedBox(height: 10),
        const Text('Tell patients a bit about yourself',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 28),
        CustomTextField(
          controller: _descController,
          label: 'Description / Services',
          hint: 'e.g., I provide first-aid and basic medication in my area...',
          prefixIcon: Icons.description_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 28),


        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile Summary',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              _summaryRow('Name', _nameController.text),
              _summaryRow('Email', _emailController.text),
              _summaryRow('Phone', _phoneController.text),
              _summaryRow('Role', _helperTypeLabel(_selectedType)),
              _summaryRow('Area', _addressController.text),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Obx(() => CustomButton(
              label: 'Create Helper Account',
              isLoading: _authController.isLoading.value,
              onPressed: _handleSignup,
            )),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
              child: Text(value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  String _helperTypeLabel(HelperType type) {
    switch (type) {
      case HelperType.ashaWorker:
        return 'ASHA Worker';
      case HelperType.chemist:
        return 'Chemist';
      case HelperType.localClinic:
        return 'Local Clinic';
      case HelperType.volunteer:
        return 'Volunteer';
      case HelperType.other:
        return 'Other';
    }
  }
}
