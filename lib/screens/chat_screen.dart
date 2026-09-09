import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import '../resources/AppTheme.dart';
import '../resources/responsive.dart';
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
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    _chatController = Get.put(ChatController());

    if (widget.initialSymptom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 600));
        _chatController.sendMessage(widget.initialSymptom!);
      });
    }

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
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = _chatController.messages;
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(4).clamp(12.0, 24.0),
                  vertical: context.hp(1.5).clamp(8.0, 16.0),
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageItem(message, index);
                },
              );
            }),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: context.r(20)),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: context.r(38),
            height: context.r(38),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF089A97)],
              ),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Center(
              child: Text('🩺', style: TextStyle(fontSize: context.sp(18))),
            ),
          ),
          SizedBox(width: context.wp(2.5).clamp(8.0, 14.0)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DocTalk AI',
                style: TextStyle(
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Lato',
                ),
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: context.sp(11),
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
          icon: Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: context.r(22)),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(16))),
                title: Text(
                  'New Consultation?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: context.sp(17),
                  ),
                ),
                content: Text(
                  'This will start a fresh health check. Your previous chat will be saved in History.',
                  style: TextStyle(fontSize: context.sp(14), height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: TextStyle(fontSize: context.sp(14))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _chatController.resetChat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 0),
                      padding: EdgeInsets.symmetric(
                          horizontal: context.r(16), vertical: context.hp(1)),
                    ),
                    child: Text('Start Fresh', style: TextStyle(fontSize: context.sp(14))),
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
      return Padding(
        padding: EdgeInsets.only(bottom: context.hp(1)),
        child: const TypingIndicator(),
      );
    }

    if (message.type == MessageType.assessment && message.assessment != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: context.hp(1.5)),
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
            padding: EdgeInsets.only(
              top: context.hp(1),
              bottom: context.hp(0.5),
              left: context.wp(10).clamp(36.0, 52.0),
            ),
            child: QuickReplyChips(
              options: message.quickReplies!,
              onSelected: (option) => _sendMessage(option),
            ),
          ),
        SizedBox(height: context.hp(1)),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
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
          padding: EdgeInsets.symmetric(
            horizontal: context.wp(4).clamp(12.0, 20.0),
            vertical: context.hp(1.2).clamp(8.0, 16.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(context.r(24)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: context.r(16)),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: context.sp(15),
                            color: AppColors.textPrimary,
                            fontFamily: 'Lato',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Apne symptoms batayein...',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: context.sp(15),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: context.hp(1.2).clamp(8.0, 14.0),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(width: context.wp(2.5).clamp(8.0, 14.0)),
              Obx(() => GestureDetector(
                onTap: _chatController.isTyping.value ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: context.r(48),
                  height: context.r(48),
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
                      ? Center(
                    child: SizedBox(
                      width: context.r(20),
                      height: context.r(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textHint),
                      ),
                    ),
                  )
                      : Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: context.r(20),
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
