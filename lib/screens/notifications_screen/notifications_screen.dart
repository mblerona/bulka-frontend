import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/relative_time.dart';
import 'package:bulka_frontend/models/notification_item.dart';
import 'package:bulka_frontend/services/notifications_controller.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController _controller = NotificationsController.instance;

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

  @override
  Widget build(BuildContext context) {
    final notifications = _controller.notifications;
    final unreadCount = _controller.unreadCount;

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
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.notificationsBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppDimensions.notificationsListGap),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _controller.markAsRead(notification.id),
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
