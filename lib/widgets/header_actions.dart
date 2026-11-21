import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/notifications/notifications_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';

/// My Tickets, Notifications (with the unread badge) and Settings, as round
/// icon buttons for the top right of a green header band, above its title.
/// Not in the Figma design.
class HeaderActions extends StatelessWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationsBloc, int>(
      (bloc) => bloc.state.unreadCount,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeaderIconButton(
          icon: Icons.confirmation_number_outlined,
          tooltip: AppStrings.headerTicketsTooltip,
          onPressed: () => context.push(AppRoutes.tickets),
        ),
        const SizedBox(width: AppDimensions.headerActionsGap),
        HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: AppStrings.headerNotificationsTooltip,
          badgeCount: unread,
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        const SizedBox(width: AppDimensions.headerActionsGap),
        HeaderIconButton(
          icon: Icons.settings_outlined,
          tooltip: AppStrings.headerSettingsTooltip,
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
}

/// A round icon button for a green header band (32px, white icon).
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount = 0,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badgeCount;

  /// Shows a spinner instead of the icon and ignores taps.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.headerActionBackground,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : onPressed,
          child: SizedBox(
            width: AppDimensions.headerActionSize,
            height: AppDimensions.headerActionSize,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (busy)
                  const SizedBox.square(
                    dimension: AppDimensions.headerActionSpinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: AppDimensions.headerActionSpinnerStroke,
                      color: AppColors.white,
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: AppDimensions.headerActionIconSize,
                    color: AppColors.white,
                    semanticLabel: tooltip,
                  ),
                if (badgeCount > 0)
                  Positioned(
                    top: AppDimensions.headerActionBadgeOffset,
                    right: AppDimensions.headerActionBadgeOffset,
                    child: _Badge(count: badgeCount),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Same look as the bottom nav's Messages badge.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppDimensions.bottomNavBadgeSize,
        minHeight: AppDimensions.bottomNavBadgeSize,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.bottomNavBadgeHorizontalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.settingsDangerColor,
        shape: BoxShape.circle,
        // Separates it from the button it overlaps.
        border: Border.all(color: AppColors.agroForest950, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: AppDimensions.bottomNavBadgeFontSize,
          color: AppColors.white,
        ),
      ),
    );
  }
}
