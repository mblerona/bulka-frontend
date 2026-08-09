import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// A single tab's icon + label for [BottomNavBar].
class BottomNavItem {
  const BottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// DS/Nav — the bottom tab bar. Tourist and Provider share the exact same
/// container/tab styling in Figma (DS/Nav/Tourist, DS/Nav/Provider); only
/// the 5 tabs' icons/labels differ, so this is one widget parameterized by
/// [items] rather than two near-duplicate ones. Use [touristBottomNavItems]
/// / [providerBottomNavItems] below for those two tab sets.
///
/// This only renders the bar and reports taps via [onTap] — wiring each tab
/// index to an actual screen is left to the caller (TODO once the
/// Home/Search/Bookings/Dashboard/Offers/Calendar/Messages screens exist).
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.badgeCounts = const {},
  }) : assert(items.length == 5, 'DS/Nav is designed for exactly 5 tabs');

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Tab index -> unread count. A tab is only badged when its count is > 0.
  /// Not part of [BottomNavItem] because it's runtime state, not static tab
  /// data — e.g. the "Пораки" tab's badge comes from
  /// `ChatController.instance.totalUnreadMessages`.
  final Map<int, int> badgeCounts;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.agroBorder300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _BottomNavTab(
                item: items[i],
                isSelected: i == selectedIndex,
                badgeCount: badgeCounts[i] ?? 0,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavTab extends StatelessWidget {
  const _BottomNavTab({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.agroGreen700 : AppColors.agroInk500;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: AppDimensions.bottomNavTopPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicator space is always reserved (filled only when
            // selected) so tabs don't jump vertically on switch.
            SizedBox(
              height: AppDimensions.bottomNavIndicatorHeight,
              width: AppDimensions.bottomNavIndicatorWidth,
              child: isSelected
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.agroGreen700,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.pillBorderRadius,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppDimensions.bottomNavIndicatorGap),
            SizedBox(
              width: AppDimensions.bottomNavIconSize,
              height: AppDimensions.bottomNavIconSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item.icon,
                    size: AppDimensions.bottomNavIconSize,
                    color: color,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: _NavBadge(count: badgeCount),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.bottomNavIndicatorGap),
            Text(
              item.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: AppDimensions.bottomNavLabelFontSize,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count});

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
      decoration: const BoxDecoration(
        color: AppColors.settingsDangerColor,
        shape: BoxShape.circle,
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

/// Index of the "Пораки" tab — identical in both [touristBottomNavItems]
/// and [providerBottomNavItems], which is what lets both roles' nav bars
/// badge from the one shared `ChatController.instance`.
const int navMessagesTabIndex = 3;

/// DS/Nav/Tourist — Дома, Пребарај, Резервации, Пораки, Профил.
const List<BottomNavItem> touristBottomNavItems = [
  BottomNavItem(icon: Icons.home_outlined, label: AppStrings.navTouristHome),
  BottomNavItem(icon: Icons.search, label: AppStrings.navTouristSearch),
  BottomNavItem(
    icon: Icons.calendar_month_outlined,
    label: AppStrings.navTouristBookings,
  ),
  BottomNavItem(icon: Icons.chat_bubble_outline, label: AppStrings.navMessages),
  BottomNavItem(icon: Icons.person_outline, label: AppStrings.navProfile),
];

/// DS/Nav/Provider — Табла, Понуди, Календар, Пораки, Профил.
const List<BottomNavItem> providerBottomNavItems = [
  BottomNavItem(
    icon: Icons.insert_chart_outlined_rounded,
    label: AppStrings.navProviderDashboard,
  ),
  BottomNavItem(
    icon: Icons.grid_view_outlined,
    label: AppStrings.navProviderOffers,
  ),
  BottomNavItem(
    icon: Icons.calendar_month_outlined,
    label: AppStrings.navProviderCalendar,
  ),
  BottomNavItem(icon: Icons.chat_bubble_outline, label: AppStrings.navMessages),
  BottomNavItem(icon: Icons.person_outline, label: AppStrings.navProfile),
];
