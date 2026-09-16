import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../../../resources/app_theme.dart';
import '../resources/responsive.dart';
import '../services/appoint_service.dart';
import '../services/chat_history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final historyService = ChatHistoryService();
    final appointmentService = AppointmentService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Health Records',
          style: TextStyle(
            fontSize: context.sp(17),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: AppColors.border),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: context.sp(12.5),
                  fontFamily: 'Lato',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: context.sp(12.5),
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: context.r(15)),
                        const SizedBox(width: 6),
                        const Text('Consultations'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: context.r(15)),
                        const SizedBox(width: 6),
                        const Text('Appointments'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // -- Tab 1: Consultations (your original code, untouched) â”€â”€â”€
          _ConsultationsTab(
            authController: authController,
            historyService: historyService,
          ),
          // -- Tab 2: Booked Appointments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _AppointmentsTab(service: appointmentService),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 1 - Consultations  (original logic, just moved into its own widget)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _ConsultationsTab extends StatelessWidget {
  final AuthController authController;
  final ChatHistoryService historyService;

  const _ConsultationsTab({
    required this.authController,
    required this.historyService,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userId = authController.currentUserId;
      if (userId.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primary));
      }

      return FutureBuilder<List<ChatSession>>(
        future: historyService.getUserSessions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(context.r(16)),
            itemCount: sessions.length,
            itemBuilder: (context, index) =>
                _HistoryCard(session: sessions[index]),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_rounded, color: AppColors.primary, size: context.sp(56)), // ,
          SizedBox(height: context.hp(1.6)),
          Text(
            'No consultations yet',
            style: TextStyle(
              fontSize: context.sp(17),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Lato',
            ),
          ),
          SizedBox(height: context.hp(0.8)),
          Text(
            'Tap the + button to start your\nfirst health check',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(13.5),
              color: AppColors.textSecondary.withValues(alpha:0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Tab 2 - Booked Appointments
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _AppointmentsTab extends StatefulWidget {
  final AppointmentService service;
  const _AppointmentsTab({required this.service});

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.service.getAllAppointments();
  }

  Future<void> _cancel(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(18))),
        title: Text(
          'Cancel Appointment?',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: context.sp(16),
              fontFamily: 'Lato'),
        ),
        content: Text(
          'Kya aap sach mein yeh appointment cancel karna chahte hain?',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: context.sp(13.5), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('No',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(10))),
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.cancelAppointment(id);
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
              CircularProgressIndicator(color: AppColors.primary));
        }

        final list = snapshot.data ?? [];

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.r(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: context.sp(56)), // ,
                  SizedBox(height: context.hp(1.6)),
                  Text(
                    'No appointments booked',
                    style: TextStyle(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  SizedBox(height: context.hp(0.8)),
                  Text(
                    'Chat mein "Doctor Dhundho" tap karein\naur apna pehla appointment book karein',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(13.5),
                      color: AppColors.textSecondary.withValues(alpha:0.7),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: context.hp(2.4)),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(
                      '/doctor-finder',
                      arguments: {'specialist': 'General Physician'},
                    ),
                    icon: Icon(Icons.search_rounded, size: context.r(17)),
                    label: Text('Find a Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(12))),
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => setState(_load),
          child: ListView.builder(
            padding: EdgeInsets.all(context.r(16)),
            itemCount: list.length,
            itemBuilder: (_, i) => _AppointmentCard(
              data: list[i],
              onCancel: () =>
                  _cancel(list[i]['id'] as String? ?? ''),
            ),
          ),
        );
      },
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Appointment Card
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCancel;

  const _AppointmentCard(
      {required this.data, required this.onCancel});

  String get _status => data['status'] as String? ?? 'confirmed';
  bool get _isCancelled => _status == 'cancelled';
  bool get _isCompleted => _status == 'completed';

  Color get _statusColor {
    if (_isCancelled) return AppColors.error;
    if (_isCompleted) return AppColors.success;
    return AppColors.primary;
  }

  String get _statusLabel {
    if (_isCancelled) return 'Cancelled';
    if (_isCompleted) return 'Completed';
    return 'Confirmed';
  }

  IconData get _statusIcon {
    if (_isCancelled) return Icons.cancel_outlined;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // -- Parse fields safely â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    DateTime? date;
    try {
      date = DateTime.parse(data['date'] as String? ?? '');
    } catch (_) {}

    final doctorName = data['doctorName'] as String? ?? 'Doctor';
    final spec = data['doctorSpecialization'] as String? ?? '';
    final address = data['doctorAddress'] as String? ?? '';
    final timeSlot = data['timeSlot'] as String? ?? '';
    final patientName = data['patientName'] as String? ?? '';
    final phone = data['patientPhone'] as String? ?? '';
    final reason = data['reason'] as String? ?? '';
    final fee = (data['consultationFee'] as num?)?.toInt() ?? 0;
    final rawId = data['id'] as String? ?? '';
    final shortId =
    rawId.length > 8 ? rawId.substring(rawId.length - 8) : rawId;

    return Opacity(
      opacity: _isCancelled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(context.r(18)),
          border: Border.all(
            color: _isCancelled
                ? AppColors.error.withValues(alpha:0.2)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha:_isCancelled ? 0.02 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // -- Gradient header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isCancelled
                      ? [
                    Colors.grey.withValues(alpha:0.08),
                    Colors.grey.withValues(alpha:0.04),
                  ]
                      : [
                    AppColors.primary.withValues(alpha:0.08),
                    AppColors.primaryLight.withValues(alpha:0.5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.r(18)),
                  topRight: Radius.circular(context.r(18)),
                ),
              ),
              child: Row(
                children: [
                  // Doctor avatar circle
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _isCancelled
                          ? Colors.grey.withValues(alpha:0.15)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: _isCancelled
                          ? AppColors.textHint
                          : AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 11),

                  // Doctor name + specialization
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: context.sp(13.5),
                            fontFamily: 'Lato',
                          ),
                        ),
                        if (spec.isNotEmpty)
                          Text(
                            spec,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: context.sp(11.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _statusColor.withValues(alpha:0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: context.r(11), color: _statusColor),
                        SizedBox(width: context.wp(1.0)),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -- Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 13, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + Time
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.calendar_today_rounded,
                        label: date != null
                            ? DateFormat('EEE, d MMM yyyy')
                            .format(date)
                            : '-',
                        color: AppColors.primary,
                      ),
                      SizedBox(width: context.wp(2.0)),
                      _Chip(
                        icon: Icons.access_time_rounded,
                        label:
                        timeSlot.isNotEmpty ? timeSlot : '-',
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                  SizedBox(height: context.hp(1.0)),

                  // Clinic address
                  if (address.isNotEmpty)
                    _IconRow(
                        icon: Icons.location_on_outlined,
                        text: address),

                  SizedBox(height: context.hp(0.6)),

                  // Patient info
                  _IconRow(
                    icon: Icons.person_outline_rounded,
                    text: phone.isNotEmpty
                        ? '$patientName  •  $phone'
                        : patientName,
                  ),

                  // Visit reason
                  if (reason.isNotEmpty) ...[
                    SizedBox(height: context.hp(0.6)),
                    _IconRow(
                        icon: Icons.note_alt_outlined,
                        text: reason),
                  ],

                  // Fee
                  if (fee > 0) ...[
                    SizedBox(height: context.hp(0.6)),
                    _IconRow(
                        icon: Icons.currency_rupee,
                        text: 'Consultation fee: ₹$fee'),
                  ],

                  SizedBox(height: context.hp(1.2)),
                  const Divider(height: 1, color: AppColors.border),
                  SizedBox(height: context.hp(1.0)),

                  // Bottom row: Booking ID + Cancel
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: $shortId',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!_isCancelled)
                        GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                              AppColors.error.withValues(alpha:0.06),
                              borderRadius:
                              BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.error
                                      .withValues(alpha:0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close_rounded,
                                    size: context.r(12),
                                    color: AppColors.error),
                                SizedBox(width: 4),
                                Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: context.sp(11),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Small reusable widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon,
        required this.label,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.r(12), color: color),
          SizedBox(width: context.wp(1.2)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: context.sp(11),
              fontWeight: FontWeight.w600,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.r(13), color: AppColors.textHint),
        SizedBox(width: context.wp(1.5)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: context.sp(12)),
          ),
        ),
      ],
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Original _HistoryCard - COMPLETELY UNCHANGED from your code
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class _HistoryCard extends StatelessWidget {
  final ChatSession session;

  const _HistoryCard({required this.session});

  Color get _severityColor {
    switch (session.severity) {
      case 'URGENT':
        return AppColors.urgent;
      case 'MEDIUM':
        return AppColors.medium;
      case 'LOW':
        return AppColors.low;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.r(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.firstSymptom,
                    style: TextStyle(
                      fontSize: context.sp(14.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (session.hasAssessment &&
                    session.severity.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _severityColor.withValues(alpha:0.3)),
                    ),
                    child: Text(
                      session.severity,
                      style: TextStyle(
                        fontSize: context.sp(10.5),
                        fontWeight: FontWeight.w700,
                        color: _severityColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.hp(0.8)),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: context.r(13),
                    color:
                    AppColors.textSecondary.withValues(alpha:0.6)),
                SizedBox(width: context.wp(1.0)),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a')
                      .format(session.createdAt),
                  style: TextStyle(
                    fontSize: context.sp(11.5),
                    color: AppColors.textSecondary.withValues(alpha:0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  '${session.messageCount} messages',
                  style: TextStyle(
                    fontSize: context.sp(11.5),
                    color: AppColors.textSecondary.withValues(alpha:0.7),
                  ),
                ),
              ],
            ),
            if (session.hasAssessment) ...[
              SizedBox(height: context.hp(1.0)),
              Container(height: 1, color: AppColors.border),
              SizedBox(height: context.hp(1.0)),
              Row(
                children: [
                  Icon(Icons.medical_services_outlined,
                      size: context.r(14), color: AppColors.primary),
                  SizedBox(width: context.wp(1.5)),
                  Expanded(
                    child: Text(
                      session.assessment?['likelyconditions'] !=
                          null
                          ? (session.assessment!['likelyconditions']
                      as List)
                          .take(2)
                          .join(', ')
                          : 'Assessment available',
                      style: TextStyle(
                        fontSize: context.sp(11.5),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

