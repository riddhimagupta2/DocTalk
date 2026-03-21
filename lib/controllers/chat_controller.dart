import 'package:get/get.dart';
import '../models/chat_message_model.dart';
import '../services/gemini_service.dart';
import '../services/chat_history_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  final ChatHistoryService _historyService = ChatHistoryService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isSessionStarted = false.obs;
  final RxString sessionId = ''.obs;
  final RxBool showDoctorFinder = false.obs;
  final Rx<AssessmentData?> currentAssessment = Rx<AssessmentData?>(null);


  bool _isSending = false;
  String? _lastSentMessage;
  DateTime? _lastSendTime;

  @override
  void onInit() {
    super.onInit();
    _startSession();
  }

  void _startSession() {
    messages.add(ChatMessage.ai(
      'Namaste! 🙏 Main DocTalk hoon.\n\nAaj aap kaisa feel kar rahe hain? Symptoms batayein.',
      quickReplies: ['Sar dard', 'Bukhar', 'Pet dard', 'Khasi', 'Kuch aur'],
    ));
    isSessionStarted.value = true;
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    print('CONTROLLER: sendMessage called');
    print('Message: "$trimmedText"');
    print('Is sending: $_isSending');
    print('Last send: $_lastSendTime');


    if (_isSending) {
      print('LAYER 1 BLOCKED: Already sending');
      Get.snackbar(
        'Please Wait',
        'Processing previous message...',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
      return;
    }


    if (_lastSentMessage == trimmedText) {
      print('LAYER 2 BLOCKED: Duplicate message');
      Get.snackbar(
        'Duplicate',
        'Already processing this message',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );
      await Future.delayed(const Duration(seconds: 2));
      return;
    }


    if (_lastSendTime != null) {
      final gap = DateTime.now().difference(_lastSendTime!);
      if (gap.inSeconds < 3) {
        print(' LAYER 3 BLOCKED: Too fast (${gap.inSeconds}s gap)');
        Get.snackbar(
          'Too Fast',
          'Wait ${3 - gap.inSeconds} seconds',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
        );
        return;
      }
    }

    if (_isDoctorFinderTrigger(trimmedText)) {
      print('DOCTOR FINDER TRIGGERED');

      final userMessage = ChatMessage.user(trimmedText);
      messages.add(userMessage);

      final confirmMsg = ChatMessage.ai('Finding nearby doctors... 🗺️');
      messages.add(confirmMsg);

      await Future.delayed(const Duration(milliseconds: 500));

      Get.toNamed('/doctor-finder', arguments: {
        'specialist': currentAssessment.value?.recommendedSpecialist ??
            'General Physician',
      });

      return;
    }

    _isSending = true;
    _lastSentMessage = trimmedText;
    _lastSendTime = DateTime.now();

    try {
      final userMessage = ChatMessage.user(trimmedText);
      messages.add(userMessage);

      if (sessionId.value.isEmpty) {
        await _createFirebaseSession(trimmedText);
      }

      _saveMessageToFirebase(userMessage);

      isTyping.value = true;
      messages.add(ChatMessage.typing());


      final response = await _geminiService.sendMessage(trimmedText);

      messages.removeWhere((m) => m.isTyping);
      isTyping.value = false;

      if (response.isError) {
        final errorMsg = ChatMessage.ai(response.text);
        messages.add(errorMsg);
        return;
      }

      if (response.hasAssessment) {
        print('ASSESSMENT RECEIVED');

        final summaryMsg = ChatMessage.ai(
          response.text,
          quickReplies: response.hasQuickReplies ? response.quickReplies : null,
        );
        messages.add(summaryMsg);
        _saveMessageToFirebase(summaryMsg);

        final assessmentMsg = ChatMessage.assessment(response.assessment!);
        messages.add(assessmentMsg);
        currentAssessment.value = response.assessment;

        if (sessionId.value.isNotEmpty) {
          await _historyService.saveAssessment(
            userId: _authController.currentUserId,
            sessionId: sessionId.value,
            assessment: response.assessment!,
          );
        }

        await Future.delayed(const Duration(milliseconds: 800));

        final doctorPromptMsg = ChatMessage.ai(
          'Kya aap nearby ${response.assessment!.recommendedSpecialist} dhundna chahenge? 🗺️',
          quickReplies: [
            '📍 Haan, Doctor Dhundho',
            '🏠 Ghar pe manage',
            '❓ Questions'
          ],
        );
        messages.add(doctorPromptMsg);
        _saveMessageToFirebase(doctorPromptMsg);
      } else {
        final aiMsg = ChatMessage.ai(
          response.text,
          quickReplies: response.hasQuickReplies ? response.quickReplies : null,
        );
        messages.add(aiMsg);
        _saveMessageToFirebase(aiMsg);
      }
    } catch (e) {
      messages.removeWhere((m) => m.isTyping);
      isTyping.value = false;

      final errorMsg = ChatMessage.ai('Error: ${e.toString()}');
      messages.add(errorMsg);
      print('Error: $e');
    } finally {

      await Future.delayed(const Duration(seconds: 3));
      _isSending = false;
      print('🔓 CONTROLLER UNLOCKED');
    }
  }

  bool _isDoctorFinderTrigger(String text) {
    final lower = text.toLowerCase();
    return text == '📍 Haan, Doctor Dhundho' ||
        lower.contains('doctor dhundho') ||
        lower.contains('doctor dhundo') ||
        lower.contains('find doctor');
  }

  Future<void> _createFirebaseSession(String firstMessage) async {
    try {
      final id = await _historyService.createSession(
        _authController.currentUserId,
        firstMessage,
      );
      sessionId.value = id;
    } catch (e) {
      print('Session error: $e');
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
      print('Save error: $e');
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
    _lastSendTime = null;
    _geminiService.resetSession();
    _startSession();
  }

  @override
  void onClose() {
    _isSending = false;
    super.onClose();
  }
}
