import 'package:get/get.dart';
import '../models/chat_message_model.dart';
import '../services/gemini_service.dart';
import '../services/chat_history_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  final ChatHistoryService _historyService = ChatHistoryService();
  final AuthController _authController = Get.find<AuthController>();

  // Observables
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isSessionStarted = false.obs;
  final RxString sessionId = ''.obs;
  final RxBool showDoctorFinder = false.obs;
  final Rx<AssessmentData?> currentAssessment = Rx<AssessmentData?>(null);

  // ══════════════════════════════════════════════════
  // 🛡️ DUPLICATE SEND PROTECTION
  // ══════════════════════════════════════════════════
  bool _isSending = false;
  String? _lastSentMessage;

  @override
  void onInit() {
    super.onInit();
    _startSession();
  }

  void _startSession() {
    // Add initial greeting message
    messages.add(ChatMessage.ai(
      'Namaste! 🙏 Main MediSaathi hoon — aapka AI health companion.\n\nAaj aap kaisa feel kar rahe hain? Please mujhe batayein ki aap kya symptoms feel kar rahe hain. Main aapki poori koshish se help karoonga.',
      quickReplies: ['Sar dard hai', 'Bukhar hai', 'Pet mein dard', 'Khasi / Nazla', 'Kuch aur'],
    ));
    isSessionStarted.value = true;
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // ══════════════════════════════════════════════════
    // 🔒 PROTECTION 1: Block if already sending
    // ══════════════════════════════════════════════════
    if (_isSending) {
      print('⚠️ ChatController: Blocked duplicate send - already processing');
      return;
    }

    // ══════════════════════════════════════════════════
    // 🔒 PROTECTION 2: Block exact duplicate message
    // ══════════════════════════════════════════════════
    if (_lastSentMessage == trimmedText) {
      print('⚠️ ChatController: Blocked exact duplicate: "$trimmedText"');
      await Future.delayed(const Duration(seconds: 1));
    }

    // ══════════════════════════════════════════════════
    // 🚨 SPECIAL HANDLING: Doctor Finder Trigger
    // Open map IMMEDIATELY without AI response
    // ══════════════════════════════════════════════════
    if (_isDoctorFinderTrigger(trimmedText)) {
      print('✅ Doctor finder triggered! Opening map...');

      // Add user message to chat
      final userMessage = ChatMessage.user(trimmedText);
      messages.add(userMessage);
      _saveMessageToFirebase(userMessage);

      // Add confirmation message (no AI needed)
      final confirmMsg = ChatMessage.ai(
        'Bilkul! Main aapko nearby doctors dikha raha hoon Google Maps par. Ek second... 🗺️',
      );
      messages.add(confirmMsg);

      // Wait a tiny moment for smooth transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to doctor finder
      Get.toNamed('/doctor-finder', arguments: {
        'specialist': currentAssessment.value?.recommendedSpecialist ?? 'General Physician',
      });

      return; // Stop here - don't send to AI
    }

    // ══════════════════════════════════════════════════
    // 🔐 LOCK SENDING (for regular messages)
    // ══════════════════════════════════════════════════
    _isSending = true;
    _lastSentMessage = trimmedText;

    try {
      // Add user message to chat
      final userMessage = ChatMessage.user(trimmedText);
      messages.add(userMessage);

      // Create session in Firebase on first user message
      if (sessionId.value.isEmpty) {
        await _createFirebaseSession(trimmedText);
      }

      // Save user message to Firebase
      _saveMessageToFirebase(userMessage);

      // Show typing indicator
      isTyping.value = true;
      messages.add(ChatMessage.typing());

      // ══════════════════════════════════════════════════
      // 🚀 GET AI RESPONSE
      // ══════════════════════════════════════════════════
      final response = await _geminiService.sendMessage(trimmedText);

      // Remove typing indicator
      messages.removeWhere((m) => m.isTyping);
      isTyping.value = false;

      // If response is an error (like quota exceeded), show it
      if (response.isError) {
        final errorMsg = ChatMessage.ai(response.text);
        messages.add(errorMsg);
        return;
      }

      // ══════════════════════════════════════════════════
      // Handle successful response
      // ══════════════════════════════════════════════════

      if (response.hasAssessment) {
        // Add the summary text message
        final summaryMsg = ChatMessage.ai(
          response.text,
          quickReplies: response.hasQuickReplies ? response.quickReplies : null,
        );
        messages.add(summaryMsg);
        _saveMessageToFirebase(summaryMsg);

        // Add assessment card
        final assessmentMsg = ChatMessage.assessment(response.assessment!);
        messages.add(assessmentMsg);
        currentAssessment.value = response.assessment;

        // Save assessment to Firebase
        if (sessionId.value.isNotEmpty) {
          await _historyService.saveAssessment(
            userId: _authController.currentUserId,
            sessionId: sessionId.value,
            assessment: response.assessment!,
          );
        }

        // Show doctor finder prompt after a short delay
        await Future.delayed(const Duration(milliseconds: 800));
        final doctorPromptMsg = ChatMessage.ai(
          'Kya aap apne paas ke ${response.assessment!.recommendedSpecialist} ko dhundna chahenge? Main aapko best doctors Google Maps par dikha sakta hoon. 🗺️',
          quickReplies: [
            '📍 Haan, Doctor Dhundho',
            '🏠 Ghar pe manage karoonga',
            '❓ Aur questions hain'
          ],
        );
        messages.add(doctorPromptMsg);
        _saveMessageToFirebase(doctorPromptMsg);
      } else {
        // Regular message (no assessment)
        final aiMsg = ChatMessage.ai(
          response.text,
          quickReplies: response.hasQuickReplies ? response.quickReplies : null,
        );
        messages.add(aiMsg);
        _saveMessageToFirebase(aiMsg);
      }

    } catch (e) {
      // Handle any unexpected errors
      messages.removeWhere((m) => m.isTyping);
      isTyping.value = false;

      final errorMsg = ChatMessage.ai(
        'Maafi chahta hoon, kuch problem aa gayi. Please dobara try karein. 🙏\n\nError: ${e.toString()}',
      );
      messages.add(errorMsg);
      print('❌ ChatController error: $e');
    } finally {
      // ══════════════════════════════════════════════════
      // 🔓 UNLOCK - allow next send
      // ══════════════════════════════════════════════════
      _isSending = false;

      // Clear last sent message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (_lastSentMessage == trimmedText) {
          _lastSentMessage = null;
        }
      });
    }
  }

  // ══════════════════════════════════════════════════
  // 🔍 Check if message should trigger doctor finder
  // ══════════════════════════════════════════════════
  bool _isDoctorFinderTrigger(String text) {
    final lowerText = text.toLowerCase();

    // Exact matches
    if (text == '📍 Haan, Doctor Dhundho') return true;

    // Contains keywords
    if (lowerText.contains('doctor dhundho') ||
        lowerText.contains('doctor dhoondho') ||
        lowerText.contains('doctor dhundo') ||
        lowerText.contains('find doctor') ||
        lowerText.contains('doctor dikhao') ||
        lowerText.contains('doctor batao')) {
      return true;
    }

    return false;
  }

  Future<void> _createFirebaseSession(String firstMessage) async {
    try {
      final id = await _historyService.createSession(
        _authController.currentUserId,
        firstMessage,
      );
      sessionId.value = id;
    } catch (e) {
      print('❌ Error creating Firebase session: $e');
    }
  }

  void _saveMessageToFirebase(ChatMessage message) {
    if (sessionId.value.isEmpty) return;
    if (message.isTyping) return;
    if (message.type == MessageType.assessment) return;

    try {
      _historyService.saveMessage(
        userId: _authController.currentUserId,
        sessionId: sessionId.value,
        message: message,
      );
    } catch (e) {
      print('❌ Error saving message to Firebase: $e');
    }
  }

  void resetChat() {
    messages.clear();
    sessionId.value = '';
    isTyping.value = false;
    showDoctorFinder.value = false;
    currentAssessment.value = null;
    _isSending = false;
    _lastSentMessage = null;
    _geminiService.resetSession();
    _startSession();
  }

  @override
  void onClose() {
    _isSending = false;
    _lastSentMessage = null;
    super.onClose();
  }
}