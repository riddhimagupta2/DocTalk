import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new chat session
  Future<String> createSession(String userId, String firstSymptom) async {
    final sessionRef = await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .add({
      'firstSymptom': firstSymptom,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'messageCount': 0,
    });
    return sessionRef.id;
  }

  // Save a message
  Future<void> saveMessage({
    required String userId,
    required String sessionId,
    required ChatMessage message,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());

    // Update session metadata
    await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
      'messageCount': FieldValue.increment(1),
    });
  }

  // Save assessment result to session
  Future<void> saveAssessment({
    required String userId,
    required String sessionId,
    required AssessmentData assessment,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .update({
      'assessment': {
        'likelyconditions': assessment.likelyconditions,
        'severity': assessment.severity,
        'specialist': assessment.recommendedSpecialist,
        'savedAt': FieldValue.serverTimestamp(),
      },
      'status': 'completed',
    });
  }

  // Get all sessions for history screen
  Future<List<ChatSession>> getUserSessions(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => ChatSession.fromFirestore(doc)).toList();
  }

  // Get messages for a session
  Future<List<Map<String, dynamic>>> getSessionMessages({
    required String userId,
    required String sessionId,
  }) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}

class ChatSession {
  final String id;
  final String firstSymptom;
  final DateTime createdAt;
  final String status;
  final int messageCount;
  final Map<String, dynamic>? assessment;

  ChatSession({
    required this.id,
    required this.firstSymptom,
    required this.createdAt,
    required this.status,
    required this.messageCount,
    this.assessment,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSession(
      id: doc.id,
      firstSymptom: data['firstSymptom'] ?? 'Health Consultation',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      messageCount: data['messageCount'] ?? 0,
      assessment: data['assessment'],
    );
  }

  String get severity => assessment?['severity'] ?? '';
  bool get hasAssessment => assessment != null;
}