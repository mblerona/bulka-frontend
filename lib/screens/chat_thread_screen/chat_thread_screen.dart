import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';
import 'package:bulka_frontend/services/chat_controller.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final ChatController _controller = ChatController.instance;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
    // Safe to call again even though Chat List already marks read at tap
    // time — markConversationRead is a no-op once nothing is unread, so
    // this only matters if the thread is ever opened another way later.
    _controller.markConversationRead(widget.conversationId);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  void _handleSend() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _controller.sendMessage(widget.conversationId, text);
    _inputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _controller.conversationById(widget.conversationId);
    final messages = conversation.messages;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _ChatThreadHeader(conversation: conversation),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.profileStatCardBackground,
              child: SafeArea(
                top: false,
                bottom: false,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.dsBodyHorizontalPadding,
                    vertical: AppDimensions.chatThreadBodyVerticalPadding,
                  ),
                  children: [
                    if (messages.isNotEmpty)
                      Text(
                        _dateDividerLabel(messages.first.timestamp),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: AppDimensions.chatThreadDateDividerFontSize,
                          color: AppColors.profileSecondaryText,
                        ),
                      ),
                    for (final message in messages) ...[
                      const SizedBox(height: AppDimensions.chatThreadBodyGap),
                      _MessageBubble(message: message),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: _ChatInputBar(
              controller: _inputController,
              onSend: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatThreadHeader extends StatelessWidget {
  const _ChatThreadHeader({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // A minimum, not a fixed height: after the 56px top padding the fixed
      // 100px left only 24px for the 38px avatar and the two text lines.
      constraints: const BoxConstraints(
        minHeight: AppDimensions.chatThreadHeaderHeight,
      ),
      padding: const EdgeInsets.only(
        left: AppDimensions.dsHeaderHorizontalPadding,
        right: AppDimensions.dsHeaderHorizontalPadding,
        top: AppDimensions.dsHeaderTopPadding,
        bottom: AppDimensions.chatThreadHeaderBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.agroForest950,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.dsRadiusSm),
          bottomRight: Radius.circular(AppDimensions.dsRadiusSm),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: AppDimensions.dsBackIconSize,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: AppDimensions.chatThreadHeaderGap),
          Image.asset(
            'assets/images/SplashScreen/logo.png',
            width: AppDimensions.chatThreadHeaderLogoSize,
            height: AppDimensions.chatThreadHeaderLogoSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppDimensions.chatThreadHeaderGap),
          Container(
            width: AppDimensions.chatThreadAvatarSize,
            height: AppDimensions.chatThreadAvatarSize,
            decoration: const BoxDecoration(
              color: AppColors.agroInk500,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              conversation.avatarInitials,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: AppDimensions.chatThreadAvatarInitialsFontSize,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.chatThreadHeaderGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.participantName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.chatThreadNameFontSize,
                    color: AppColors.white,
                  ),
                ),
                if (conversation.contextLabel != null) ...[
                  const SizedBox(height: AppDimensions.chatThreadNameColGap),
                  Text(
                    conversation.contextLabel!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.chatThreadContextFontSize,
                      color: AppColors.languageLabelText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.chatThreadBubbleMaxWidth,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.chatThreadBubbleHorizontalPadding,
              vertical: AppDimensions.chatThreadBubbleVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: message.isMine
                  ? AppColors.agroGreen700
                  : AppColors.agroCream100,
              border: message.isMine
                  ? null
                  : Border.all(color: AppColors.profileStatCardBorder),
              borderRadius: BorderRadius.circular(
                AppDimensions.chatThreadBubbleRadius,
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.chatThreadBubbleFontSize,
                color: message.isMine
                    ? AppColors.white
                    : AppColors.agroForest950,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.chatThreadInputBarHorizontalPadding,
        vertical: AppDimensions.chatThreadInputBarVerticalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.profileStatCardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.chatThreadInputPillHorizontalPadding,
                vertical: AppDimensions.chatThreadInputPillVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: AppColors.agroGreen100,
                borderRadius: BorderRadius.circular(
                  AppDimensions.pillBorderRadius,
                ),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.chatThreadInputFontSize,
                  color: AppColors.agroForest950,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.chatInputPlaceholder,
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.chatThreadInputFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.chatThreadInputBarGap),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: AppDimensions.chatThreadSendButtonSize,
              height: AppDimensions.chatThreadSendButtonSize,
              decoration: const BoxDecoration(
                color: AppColors.agroGreen700,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                AppStrings.chatSendButtonGlyph,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.chatThreadSendIconFontSize,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateDividerLabel(DateTime timestamp) {
  final now = DateTime.now();
  final isToday =
      timestamp.year == now.year &&
      timestamp.month == now.month &&
      timestamp.day == now.day;
  final time =
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}';
  if (isToday) return '${AppStrings.chatToday}, $time';
  return '${timestamp.day}.${timestamp.month}.${timestamp.year}, $time';
}
