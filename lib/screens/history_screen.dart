import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../resources/AppTheme.dart';
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
        title: const Text(
          'My Health Records',
          style: TextStyle(
            fontSize: 18,
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
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Lato',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 15),
                        SizedBox(width: 6),
                        Text('Consultations'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 15),
                        SizedBox(width: 6),
                        Text('Appointments'),
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
          // ── Tab 1: Consultations (your original code, untouched) ───
          _ConsultationsTab(
            authController: authController,
            historyService: historyService,
          ),
          // ── Tab 2: Booked Appointments ─────────────────────────────
          _AppointmentsTab(service: appointmentService),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 1 — Consultations  (original logic, just moved into its own widget)
// ══════════════════════════════════════════════════════════════════════════════

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
            return _buildEmptyState();
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) =>
                _HistoryCard(session: sessions[index]),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No consultations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to start your\nfirst health check',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 2 — Booked Appointments
// ══════════════════════════════════════════════════════════════════════════════

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
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Cancel Appointment?',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              fontFamily: 'Lato'),
        ),
        content: const Text(
          'Kya aap sach mein yeh appointment cancel karna chahte hain?',
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No',
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
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel'),
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
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📅', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'No appointments booked',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chat mein "Doctor Dhundho" tap karein\naur apna pehla appointment book karein',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(
                      '/doctor-finder',
                      arguments: {'specialist': 'General Physician'},
                    ),
                    icon: const Icon(Icons.search_rounded, size: 17),
                    label: const Text('Find a Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
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
            padding: const EdgeInsets.all(16),
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

// ══════════════════════════════════════════════════════════════════════════════
// Appointment Card
// ══════════════════════════════════════════════════════════════════════════════

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
    // ── Parse fields safely ────────────────────────────────────────
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isCancelled
                ? AppColors.error.withOpacity(0.2)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(_isCancelled ? 0.02 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Gradient header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isCancelled
                      ? [
                    Colors.grey.withOpacity(0.08),
                    Colors.grey.withOpacity(0.04),
                  ]
                      : [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primaryLight.withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
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
                          ? Colors.grey.withOpacity(0.15)
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            fontFamily: 'Lato',
                          ),
                        ),
                        if (spec.isNotEmpty)
                          Text(
                            spec,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
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
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _statusColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon,
                            size: 11, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
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
                            : '—',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.access_time_rounded,
                        label:
                        timeSlot.isNotEmpty ? timeSlot : '—',
                        color: AppColors.coral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Clinic address
                  if (address.isNotEmpty)
                    _IconRow(
                        icon: Icons.location_on_outlined,
                        text: address),

                  const SizedBox(height: 6),

                  // Patient info
                  _IconRow(
                    icon: Icons.person_outline_rounded,
                    text: phone.isNotEmpty
                        ? '$patientName  •  $phone'
                        : patientName,
                  ),

                  // Visit reason
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _IconRow(
                        icon: Icons.note_alt_outlined,
                        text: reason),
                  ],

                  // Fee
                  if (fee > 0) ...[
                    const SizedBox(height: 6),
                    _IconRow(
                        icon: Icons.currency_rupee,
                        text: 'Consultation fee: ₹$fee'),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 10),

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
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
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
                              AppColors.error.withOpacity(0.06),
                              borderRadius:
                              BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.error
                                      .withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close_rounded,
                                    size: 12,
                                    color: AppColors.error),
                                SizedBox(width: 4),
                                Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 11.5,
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

// ── Small reusable widgets ────────────────────────────────────────────────────

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
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
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
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Original _HistoryCard — COMPLETELY UNCHANGED from your code
// ══════════════════════════════════════════════════════════════════════════════

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.firstSymptom,
                    style: const TextStyle(
                      fontSize: 15,
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
                      color: _severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _severityColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      session.severity,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _severityColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 13,
                    color:
                    AppColors.textSecondary.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a')
                      .format(session.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  '${session.messageCount} messages',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (session.hasAssessment) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.medical_services_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.assessment?['likelyconditions'] !=
                          null
                          ? (session.assessment!['likelyconditions']
                      as List)
                          .take(2)
                          .join(', ')
                          : 'Assessment available',
                      style: const TextStyle(
                        fontSize: 12,
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