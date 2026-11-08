import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/notifications/notifications_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/relative_time.dart';
import 'package:bulka_frontend/models/notification_item.dart';
import 'package:bulka_frontend/widgets/load_failed_message.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    // The list first: reloading it clears the count from before.
    context.read<NotificationsBloc>()
      ..add(const NotificationsRequested())
      ..add(const UnreadNotificationsCountRequested());
  }

  /// Shown instead of the list when there are no notifications to list.
  Widget _noNotificationsMessage(NotificationsStatus status) {
    switch (status) {
      case NotificationsStatus.initial:
      case NotificationsStatus.loading:
        return const SectionLoadingIndicator();
      case NotificationsStatus.failed:
        return LoadFailedMessage(
          message: AppStrings.notificationsLoadFailed,
          onRetry: _loadNotifications,
        );
      case NotificationsStatus.loaded:
        return Text(
          AppStrings.notificationsEmpty,
          style: const TextStyle(
            fontSize: AppDimensions.dsInputFontSize,
            color: AppColors.profileSecondaryText,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = context.watch<NotificationsBloc>().state;
    final notifications = notificationsState.notifications;
    final unreadCount = notificationsState.unreadCount;
    final showMarkAll = notifications.any((n) => !n.isRead);
    const listPadding = EdgeInsets.only(
      left: AppDimensions.dsBodyHorizontalPadding,
      right: AppDimensions.dsBodyHorizontalPadding,
      top: AppDimensions.notificationsBodyTopPadding,
      bottom: AppDimensions.profileBodyBottomPadding,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.notificationsTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsHeaderSubtitleGap,
            subtitleFontSize: AppDimensions.dsSubheadingFontSize,
            // Always derived from the notification data — never hardcoded.
            subtitle: '$unreadCount ${AppStrings.notificationsUnreadSuffix}',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: notifications.isEmpty
                  ? Padding(
                      padding: listPadding,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: _noNotificationsMessage(
                          notificationsState.status,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: listPadding,
                      itemCount: notifications.length + (showMarkAll ? 1 : 0),
                      separatorBuilder: (context, index) => const SizedBox(
                        height: AppDimensions.notificationsListGap,
                      ),
                      itemBuilder: (context, index) {
                        if (showMarkAll) {
                          if (index == 0) return const _MarkAllReadLink();
                          index--;
                        }
                        final notification = notifications[index];
                        return _NotificationCard(
                          notification: notification,
                          onTap: () => context.read<NotificationsBloc>().add(
                            NotificationRead(notification.id),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mark all as read", above the list while any are unread. Not in the
/// Figma design; styled like the app's other text links ("Try again").
class _MarkAllReadLink extends StatelessWidget {
  const _MarkAllReadLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () =>
            context.read<NotificationsBloc>().add(const AllNotificationsRead()),
        child: Text(
          AppStrings.notificationsMarkAllRead,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsInputFontSize,
            color: AppColors.agroGreen600,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.notificationsCardPadding),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.agroCream100
              : AppColors.agroGreen100,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimensions.notificationsCardTitleFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                ),
                Text(
                  relativeTimeLabel(notification.timestamp),
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.notificationsCardTimestampFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.notificationsCardContentGap),
            Text(
              notification.message,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.notificationsCardMessageFontSize,
                color: AppColors.profileSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
