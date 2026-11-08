import 'package:flutter/material.dart';
import 'package:bulka_frontend/screens/route_not_found_screen/route_not_found_screen.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/models/chat_message.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Chat List already marks read at tap time; this covers opening the
    // thread directly (e.g. /messages/:id). After the first frame, because
    // the chat list underneath is built in the same frame and listens to
    // the controller. A no-op once nothing is unread.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chat = context.read<ChatBloc>();
      // The list first: loading it clears messages loaded before.
      if (chat.state.status == ChatStatus.initial) {
        chat.add(const ChatConversationsRequested());
      }
      _loadMessages();
      chat.add(ConversationRead(widget.conversationId));
    });
  }

  void _loadMessages() {
    context.read<ChatBloc>().add(
      ChatConversationDetailsRequested(widget.conversationId),
    );
  }

  /// Shows the newest message once the messages arrive.
  void _scrollToNewest({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final end = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          end,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(end);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    context.read<ChatBloc>().add(
      ChatMessageSent(conversationId: widget.conversationId, text: text),
    );
    _inputController.clear();
    _scrollToNewest(animate: true);
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatBloc>().state;
    final id = widget.conversationId;
    final conversation = chat.detailsFor(id);
    final messagesStatus = chat.detailsStatusFor(id);
    if (conversation == null) {
      // Opened directly (e.g. /messages/:id): wait for the list or the
      // messages, whichever finds it.
      final waiting = [
        chat.status,
        messagesStatus,
      ].any((s) => s == ChatStatus.initial || s == ChatStatus.loading);
      if (waiting) {
        return const Scaffold(
          backgroundColor: AppColors.white,
          body: SectionLoadingIndicator(),
        );
      }
      // E.g. an old /messages/:id link.
      return const RouteNotFoundScreen();
    }
    final messages = conversation.messages;
    final myUserId = context.watch<AuthBloc>().state.user?.id;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.detailsStatusFor(id) != ChatStatus.loaded &&
          current.detailsStatusFor(id) == ChatStatus.loaded,
      listener: (context, _) => _scrollToNewest(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            _ChatThreadHeader(
              conversation: conversation,
              name: conversation.participantNameFor(myUserId),
            ),
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
                      if (messages.isEmpty)
                        switch (messagesStatus) {
                          ChatStatus.failed => LoadFailedMessage(
                            message: AppStrings.chatMessagesLoadFailed,
                            onRetry: _loadMessages,
                          ),
                          ChatStatus.loaded || ChatStatus.notFound => Text(
                            AppStrings.chatNoMessages,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: AppDimensions.dsInputFontSize,
                              color: AppColors.profileSecondaryText,
                            ),
                          ),
                          _ => const SectionLoadingIndicator(),
                        },
                      if (messages.isNotEmpty)
                        Text(
                          _dateDividerLabel(messages.first.timestamp),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize:
                                AppDimensions.chatThreadDateDividerFontSize,
                            color: AppColors.profileSecondaryText,
                          ),
                        ),
                      for (final message in messages) ...[
                        const SizedBox(height: AppDimensions.chatThreadBodyGap),
                        _MessageBubble(
                          message: message,
                          isMine: message.isMineFor(myUserId),
                        ),
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
      ),
    );
  }
}

class _ChatThreadHeader extends StatelessWidget {
  const _ChatThreadHeader({required this.conversation, required this.name});

  final ChatConversation conversation;

  /// The other person's name.
  final String name;

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
              ChatConversation.initialsOf(name),
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
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.chatThreadNameFontSize,
                    color: AppColors.white,
                  ),
                ),
                if (conversation.title != null) ...[
                  const SizedBox(height: AppDimensions.chatThreadNameColGap),
                  Text(
                    conversation.title!,
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
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;

  /// Sent by the signed-in user (right, green) rather than the other
  /// person (left, cream).
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMine
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
              color: isMine ? AppColors.agroGreen700 : AppColors.agroCream100,
              border: isMine
                  ? null
                  : Border.all(color: AppColors.profileStatCardBorder),
              borderRadius: BorderRadius.circular(
                AppDimensions.chatThreadBubbleRadius,
              ),
            ),
            child: Text(
              message.isDeleted ? AppStrings.chatMessageDeleted : message.text,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: message.isDeleted ? FontStyle.italic : null,
                fontSize: AppDimensions.chatThreadBubbleFontSize,
                color: isMine ? AppColors.white : AppColors.agroForest950,
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
