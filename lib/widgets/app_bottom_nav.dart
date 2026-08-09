import 'package:flutter/material.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/services/chat_controller.dart';
import 'package:bulka_frontend/widgets/bottom_nav_bar.dart';

/// [BottomNavBar] itself stays generic (icons/labels/badges only) — these
/// two wrappers are what actually know that tab [navMessagesTabIndex]
/// ("Пораки") opens the Chat List screen and carries the shared
/// [ChatController.instance] unread-messages badge. (It previously opened
/// the Notifications screen — that was a mistake; Notifications is a
/// separate feature with its own screen/controller/badge, untouched here.)
/// Everything else about the Tourist/Provider nav bars (styling, other
/// tabs) is untouched; tapping any other tab just forwards to [onOtherTap]
/// — a TODO for the caller until the Home/Search/Bookings/Dashboard/
/// Offers/Calendar destination screens exist.
class TouristBottomNav extends StatelessWidget {
  const TouristBottomNav({
    super.key,
    required this.selectedIndex,
    this.onOtherTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onOtherTap;

  @override
  Widget build(BuildContext context) {
    return _NotificationAwareBottomNav(
      items: touristBottomNavItems,
      selectedIndex: selectedIndex,
      onOtherTap: onOtherTap,
    );
  }
}

class ProviderBottomNav extends StatelessWidget {
  const ProviderBottomNav({
    super.key,
    required this.selectedIndex,
    this.onOtherTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onOtherTap;

  @override
  Widget build(BuildContext context) {
    return _NotificationAwareBottomNav(
      items: providerBottomNavItems,
      selectedIndex: selectedIndex,
      onOtherTap: onOtherTap,
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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatListScreen()),
      );
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
