import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../resources/AppRoutes.dart';
import '../resources/AppTheme.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  // Flag to skip auto-navigation during signup (prevents race condition)
  bool _skipNextAuthRoute = false;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    // If a signup method will handle navigation itself, skip
    if (_skipNextAuthRoute) {
      _skipNextAuthRoute = false;
      return;
    }

    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.login);
    } else {
      await _fetchUserData(user.uid);
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userModel.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // ── SIGN UP ──
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      _skipNextAuthRoute = true; // We'll navigate manually

      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await credential.user?.updateDisplayName(name.trim());

      final newUser = UserModel(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toFirestore());

      userModel.value = newUser;

      Get.snackbar(
        'Welcome to DocTalk! 🎉',
        'Account created successfully, ${name.split(' ').first}!',
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );

      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _skipNextAuthRoute = false;
      _handleAuthError(e);
    } catch (e) {
      isLoading.value = false;
      _skipNextAuthRoute = false;
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── LOGIN ──
  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      Get.snackbar(
        'Welcome back! 👋',
        'Great to see you again!',
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _handleAuthError(e);
    } catch (e) {
      isLoading.value = false;
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── LOGOUT ──
  Future<void> logout() async {
    try {
      await _auth.signOut();
      userModel.value = null;
    } catch (e) {
      _showError('Error signing out. Please try again.');
    }
  }

  // ── ERROR HANDLING ──
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered. Please login.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'weak-password':
        message = 'Password should be at least 6 characters.';
        break;
      case 'user-not-found':
        message = 'No account found with this email. Please sign up.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please check and try again.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please try again.';
    }
    _showError(message);
  }

  void _showError(String message) {
    Get.snackbar(
      'Oops!',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  bool get isLoggedIn => firebaseUser.value != null;
  String get currentUserId => firebaseUser.value?.uid ?? '';
  String get userName =>
      userModel.value?.name ?? firebaseUser.value?.displayName ?? 'User';
  String get userEmail => firebaseUser.value?.email ?? '';
  String get userFirstName => userName.split(' ').first;
}
