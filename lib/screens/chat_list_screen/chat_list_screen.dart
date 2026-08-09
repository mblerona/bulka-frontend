import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/relative_time.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/screens/chat_thread_screen/chat_thread_screen.dart';
import 'package:bulka_frontend/services/chat_controller.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController _controller = ChatController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  void _openConversation(ChatConversation conversation) {
    // Mark read at tap time (not inside the thread screen) so the badge —
    // here, on the navbar, everywhere — updates before the thread even
    // finishes animating in.
    _controller.markConversationRead(conversation.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatThreadScreen(conversationId: conversation.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _controller.conversations;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.navMessages,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.chatListBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                children: [
                  for (var i = 0; i < conversations.length; i++) ...[
                    _ChatRow(
                      conversation: conversations[i],
                      onTap: () => _openConversation(conversations[i]),
                    ),
                    if (i != conversations.length - 1) ...[
                      const SizedBox(height: AppDimensions.chatListRowGap),
                      Container(
                        height: 1,
                        color: AppColors.profileStatCardBorder,
                      ),
                      const SizedBox(height: AppDimensions.chatListRowGap),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = conversation.latestMessage;
    final unreadCount = conversation.unreadCount;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.chatListRowHorizontalPadding,
          vertical: AppDimensions.chatListRowVerticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: AppDimensions.chatListAvatarSize,
              height: AppDimensions.chatListAvatarSize,
              decoration: const BoxDecoration(
                color: AppColors.profileSoftMint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                conversation.avatarInitials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimensions.chatListAvatarInitialsFontSize,
                  color: AppColors.agroInk500,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.chatListRowContentGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.participantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.chatListNameFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                  if (conversation.contextLabel != null) ...[
                    const SizedBox(height: AppDimensions.chatListContentGap),
                    Text(
                      conversation.contextLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.chatListContextFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                  ],
                  if (latest != null) ...[
                    const SizedBox(height: AppDimensions.chatListContentGap),
                    Text(
                      latest.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: AppDimensions.chatListPreviewFontSize,
                        color: AppColors.profileSecondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.chatListRowContentGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (latest != null)
                  Text(
                    relativeTimeLabel(latest.timestamp),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: AppDimensions.chatListTimestampFontSize,
                      color: AppColors.profileSecondaryText,
                    ),
                  ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: AppDimensions.chatListMetaGap),
                  _UnreadBadge(count: unreadCount),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.chatListBadgeHorizontalPadding,
        vertical: AppDimensions.chatListBadgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.agroForest950,
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: AppDimensions.chatListBadgeFontSize,
          color: AppColors.white,
        ),
      ),
    );
  }
}
