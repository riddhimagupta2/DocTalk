class AppRoutes {
  // ── Auth ────────────────────────────────────────────────
  static const splash = '/splash';
  static const roleSelection = '/role-selection';
  static const login = '/login';
  static const signup = '/signup';

  // ── Core ────────────────────────────────────────────────
  static const home = '/home';
  static const chat = '/chat';
  static const community = '/community';

  // ── Doctor Finder + Booking ──────────────────────────────
  static const doctorFinder = '/doctor-finder';
  static const doctorDetails = '/doctor-details';
  static const booking = '/booking';
  static const bookingConfirmation = '/booking-confirmation';
  static const patientAppointments = '/patient-appointments';

  // ── AI Medical Image Analysis ─────────────────────────────
  static const imageAnalysis = '/image-analysis';
  static const imageAnalysisHistory = '/image-analysis-history';

  // ── Doctor Portal ─────────────────────────────────────────
  static const doctorRegistration = '/doctor-registration';
  static const doctorPending = '/doctor-pending';
  static const doctorDashboard = '/doctor-dashboard';
  static const doctorSchedule = '/doctor-schedule';
  static const doctorPrescription = '/doctor-prescription';
  static const doctorPatientDetail = '/doctor-patient-detail';

  // ── Admin Panel ───────────────────────────────────────────
  static const adminDashboard = '/admin-dashboard';
}
