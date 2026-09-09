import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message_model.dart';
import '../resources/AppTheme.dart';
import '../resources/responsive.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = (context.wp(78)).clamp(220.0, 520.0);

    return Padding(
      padding: EdgeInsets.only(bottom: context.hp(0.5)),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(context),
          if (!isUser) SizedBox(width: context.wp(2).clamp(6.0, 10.0)),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.r(16),
                    vertical: context.hp(1.4).clamp(10.0, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.r(18)),
                      topRight: Radius.circular(context.r(18)),
                      bottomLeft:
                      Radius.circular(isUser ? context.r(18) : 4),
                      bottomRight:
                      Radius.circular(isUser ? 4 : context.r(18)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? AppColors.primary : Colors.black)
                            .withOpacity(isUser ? 0.2 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: maxBubbleWidth,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: context.sp(15),
                      height: 1.5,
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
                SizedBox(height: context.hp(0.5)),
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: TextStyle(
                    fontSize: context.sp(10),
                    color: AppColors.textHint.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: context.wp(2).clamp(6.0, 10.0)),
          if (isUser) _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: context.r(32),
      height: context.r(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF089A97)],
        ),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Center(
        child: Text('🩺', style: TextStyle(fontSize: context.sp(16))),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: context.r(32),
      height: context.r(32),
      decoration: BoxDecoration(
        color: AppColors.coral.withOpacity(0.15),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: context.r(18),
          color: AppColors.coral,
        ),
      ),
    );
  }
}
