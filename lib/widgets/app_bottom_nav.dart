import 'package:flutter/material.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_availability_calendar_screen/provider_availability_calendar_screen.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/provider_offers_screen/provider_offers_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/search_results_screen/search_results_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';
import 'package:bulka_frontend/screens/tourist_my_reservations_screen/tourist_my_reservations_screen.dart';
import 'package:bulka_frontend/services/chat_controller.dart';
import 'package:bulka_frontend/widgets/bottom_nav_bar.dart';

/// [BottomNavBar] itself stays generic (icons/labels/badges only) — these
/// two wrappers are what actually know that tab [navMessagesTabIndex]
/// ("Пораки") opens the Chat List screen and carries the shared
/// [ChatController.instance] unread-messages badge. (It previously opened
/// the Notifications screen — that was a mistake; Notifications is a
/// separate feature with its own screen/controller/badge, untouched here.)
class TouristBottomNav extends StatelessWidget {
  const TouristBottomNav({
    super.key,
    required this.selectedIndex,
    this.onOtherTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onOtherTap;

  static const int _homeTabIndex = 0;
  static const int _searchTabIndex = 1;
  static const int _reservationsTabIndex = 2;
  static const int _profileTabIndex = 4;

  /// Resolves every Tourist tab that has a real destination today,
  /// centralized here (same architecture `ProviderBottomNav` already
  /// uses for its own tabs) rather than copied into every caller. Each
  /// case is guarded against re-pushing a duplicate copy of the screen
  /// the user is already on. [onOtherTap] remains the escape hatch for
  /// any future tab that doesn't have one yet — none do currently.
  void _handleOtherTap(BuildContext context, int index) {
    switch (index) {
      case _homeTabIndex:
        if (selectedIndex != _homeTabIndex) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TouristHomeScreen()));
        }
        break;
      case _searchTabIndex:
        // Lands on the existing Search Results screen against whatever
        // `SearchController` currently holds (an unset filter shows every
        // active listing) — the full Search Filters sheet is still one
        // tap away from there, so this doesn't need a second search
        // entry point invented just for this tab.
        if (selectedIndex != _searchTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
          );
        }
        break;
      case _reservationsTabIndex:
        if (selectedIndex != _reservationsTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TouristMyReservationsScreen(),
            ),
          );
        }
        break;
      case _profileTabIndex:
        if (selectedIndex != _profileTabIndex) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
        break;
      default:
        onOtherTap?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationAwareBottomNav(
      items: touristBottomNavItems,
      selectedIndex: selectedIndex,
      onOtherTap: (index) => _handleOtherTap(context, index),
    );
  }
}

/// Unlike [TouristBottomNav], this wrapper also resolves four more tabs
/// itself — "Табла" (→ [ProviderDashboardScreen]), "Понуди"
/// (→ [ProviderOffersScreen]), "Календар"
/// (→ [ProviderAvailabilityCalendarScreen]) and "Профил"
/// (→ [ProviderProfileScreen]), all of which already have a real screen
/// to open. That routing logic lives here, in the Provider-specific
/// wrapper, rather than in the shared [_NotificationAwareBottomNav]/
/// [BottomNavBar] internals both roles use — so Tourist is completely
/// unaffected.
class ProviderBottomNav extends StatelessWidget {
  const ProviderBottomNav({
    super.key,
    required this.selectedIndex,
    this.onOtherTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onOtherTap;

  static const int _dashboardTabIndex = 0;
  static const int _offersTabIndex = 1;
  static const int _calendarTabIndex = 2;
  static const int _profileTabIndex = 4;

  void _handleOtherTap(BuildContext context, int index) {
    switch (index) {
      case _dashboardTabIndex:
        if (selectedIndex != _dashboardTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProviderDashboardScreen()),
          );
        }
        break;
      case _offersTabIndex:
        if (selectedIndex != _offersTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProviderOffersScreen()),
          );
        }
        break;
      case _calendarTabIndex:
        if (selectedIndex != _calendarTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ProviderAvailabilityCalendarScreen(),
            ),
          );
        }
        break;
      case _profileTabIndex:
        if (selectedIndex != _profileTabIndex) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProviderProfileScreen()),
          );
        }
        break;
      default:
        onOtherTap?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationAwareBottomNav(
      items: providerBottomNavItems,
      selectedIndex: selectedIndex,
      onOtherTap: (index) => _handleOtherTap(context, index),
    );
  }
}

class _NotificationAwareBottomNav extends StatelessWidget {
  const _NotificationAwareBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onOtherTap,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onOtherTap;

  void _handleTap(BuildContext context, int index) {
    if (index == navMessagesTabIndex) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ChatListScreen()));
      return;
    }
    onOtherTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatController.instance,
      builder: (context, _) {
        final unreadCount = ChatController.instance.totalUnreadMessages;
        return BottomNavBar(
          items: items,
          selectedIndex: selectedIndex,
          badgeCounts: unreadCount > 0
              ? {navMessagesTabIndex: unreadCount}
              : const {},
          onTap: (index) => _handleTap(context, index),
        );
      },
    );
  }
}
