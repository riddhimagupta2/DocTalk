import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import '../resources/AppTheme.dart';
import '../widgets/assesment_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/quick_reply_chips.dart';

class ChatScreen extends StatefulWidget {
  final String? initialSymptom;

  const ChatScreen({super.key, this.initialSymptom});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController _chatController;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize chat controller fresh for each session
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    _chatController = Get.put(ChatController());

    // If opened with initial symptom (from quick start cards)
    if (widget.initialSymptom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 600));
        _chatController.sendMessage(widget.initialSymptom!);
      });
    }

    // Auto-scroll on new messages
    _chatController.messages.listen((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final message = text ?? _inputController.text.trim();
    if (message.isEmpty) return;
    _inputController.clear();
    _chatController.sendMessage(message);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              final messages = _chatController.messages;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageItem(message, index);
                },
              );
            }),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () {
          Get.back();
        },
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF089A97)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🩺', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DocTalk AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Lato',
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.success,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: 22),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: const Text(
                  'New Consultation?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                content: const Text(
                  'This will start a fresh health check. Your previous chat will be saved in History.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _chatController.resetChat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Start Fresh'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, int index) {
    if (message.isTyping) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: TypingIndicator(),
      );
    }

    if (message.type == MessageType.assessment && message.assessment != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AssessmentCard(assessment: message.assessment!),
      );
    }

    return Column(
      crossAxisAlignment: message.role == MessageRole.user
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        MessageBubble(message: message),
        if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 48),
            child: QuickReplyChips(
              options: message.quickReplies!,
              onSelected: (option) => _sendMessage(option),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontFamily: 'Lato',
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Apne symptoms batayein...',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Send button
              Obx(() => GestureDetector(
                onTap: _chatController.isTyping.value ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _chatController.isTyping.value
                        ? null
                        : const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF089A97)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: _chatController.isTyping.value
                        ? AppColors.border
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: _chatController.isTyping.value
                        ? []
                        : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _chatController.isTyping.value
                      ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textHint),
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}