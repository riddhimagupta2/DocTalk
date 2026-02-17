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
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(text.trim());
    messages.add(userMessage);

    // Create session in Firebase on first user message
    if (sessionId.value.isEmpty) {
      await _createFirebaseSession(text.trim());
    }

    // Save user message
    _saveMessageToFirebase(userMessage);

    // Show typing indicator
    isTyping.value = true;
    messages.add(ChatMessage.typing());

    // Get AI response
    final response = await _geminiService.sendMessage(text.trim());

    // Remove typing indicator
    messages.removeWhere((m) => m.isTyping);
    isTyping.value = false;

    // Handle assessment
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
        quickReplies: ['📍 Haan, Doctor Dhundho', '🏠 Ghar pe manage karoonga', '❓ Aur questions hain'],
      );
      messages.add(doctorPromptMsg);
      _saveMessageToFirebase(doctorPromptMsg);

    } else {
      // Regular message
      final aiMsg = ChatMessage.ai(
        response.text,
        quickReplies: response.hasQuickReplies ? response.quickReplies : null,
      );
      messages.add(aiMsg);
      _saveMessageToFirebase(aiMsg);
    }

    // Handle doctor finder trigger
    if (text.toLowerCase().contains('doctor dhundho') ||
        text.toLowerCase().contains('find doctor') ||
        text == '📍 Haan, Doctor Dhundho') {
      showDoctorFinder.value = true;
      Get.toNamed('/doctor-finder', arguments: {
        'specialist': currentAssessment.value?.recommendedSpecialist ?? 'General Physician',
      });
    }
  }

  Future<void> _createFirebaseSession(String firstMessage) async {
    try {
      final id = await _historyService.createSession(
        _authController.currentUserId,
        firstMessage,
      );
      sessionId.value = id;
    } catch (e) {
      debugPrint('Error creating session: $e');
    }
  }

  void _saveMessageToFirebase(ChatMessage message) {
    if (sessionId.value.isEmpty) return;
    if (message.isTyping) return;
    if (message.type == MessageType.assessment) return;

    _historyService.saveMessage(
      userId: _authController.currentUserId,
      sessionId: sessionId.value,
      message: message,
    );
  }

  void resetChat() {
    messages.clear();
    sessionId.value = '';
    isTyping.value = false;
    showDoctorFinder.value = false;
    currentAssessment.value = null;
    _geminiService.resetSession();
    _startSession();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}