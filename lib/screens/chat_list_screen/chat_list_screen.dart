import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/relative_time.dart';
import 'package:bulka_frontend/models/chat_conversation.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    context.read<ChatBloc>().add(const ChatConversationsRequested());
  }

  /// Shown instead of the list when there are no conversations to list.
  Widget _noConversationsMessage(ChatStatus status) {
    switch (status) {
      case ChatStatus.initial:
      case ChatStatus.loading:
        return const SectionLoadingIndicator();
      case ChatStatus.failed:
      case ChatStatus.notFound: // Only for one conversation's messages.
        return LoadFailedMessage(
          message: AppStrings.chatLoadFailed,
          onRetry: _loadConversations,
        );
      case ChatStatus.loaded:
        return Text(
          AppStrings.chatEmpty,
          style: const TextStyle(
            fontSize: AppDimensions.dsInputFontSize,
            color: AppColors.profileSecondaryText,
          ),
        );
    }
  }

  void _openConversation(ChatConversation conversation) {
    // Mark read at tap time (not inside the thread screen) so the badge —
    // here, on the navbar, everywhere — updates before the thread even
    // finishes animating in.
    context.read<ChatBloc>().add(ConversationRead(conversation.id));
    context.push(AppRoutes.chat(conversation.id));
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatBloc>().state;
    final conversations = chat.conversations;
    final myUserId = context.watch<AuthBloc>().state.user?.id;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
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
                  if (conversations.isEmpty)
                    _noConversationsMessage(chat.status),
                  for (var i = 0; i < conversations.length; i++) ...[
                    _ChatRow(
                      conversation: conversations[i],
                      name: conversations[i].participantNameFor(myUserId),
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
  const _ChatRow({
    required this.conversation,
    required this.name,
    required this.onTap,
  });

  final ChatConversation conversation;

  /// The other person's name.
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = conversation.previewText;
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
                ChatConversation.initialsOf(name),
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
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.chatListNameFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                  if (conversation.title != null) ...[
                    const SizedBox(height: AppDimensions.chatListContentGap),
                    Text(
                      conversation.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.chatListContextFontSize,
                        color: AppColors.agroInk500,
                      ),
                    ),
                  ],
                  if (preview != null) ...[
                    const SizedBox(height: AppDimensions.chatListContentGap),
                    Text(
                      preview,
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
                Text(
                  relativeTimeLabel(conversation.previewTime),
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
