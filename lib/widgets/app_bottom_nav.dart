import 'package:flutter/material.dart';
import 'package:bulka_frontend/blocs/chat/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bulka_frontend/core/routing/app_routes.dart';
import 'package:bulka_frontend/widgets/bottom_nav_bar.dart';

/// The Tourist tabs: one shared [BottomNavBar] under every Tourist screen.
/// Each tab (Home, Search, Reservations, Profile) keeps its own history, so
/// switching tabs and coming back returns to where you were; tapping the
/// tab you're already on goes back to its first screen.
///
/// "Пораки" isn't a tab with its own history: it opens the chat list full
/// screen, as before.
class TouristShell extends StatelessWidget {
  const TouristShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// The nav bar position of each shell branch, in branch order
  /// (Home, Search, Reservations, Profile).
  static const _tabOfBranch = [0, 1, 2, 4];

  @override
  Widget build(BuildContext context) {
    return _TabsScaffold(
      navigationShell: navigationShell,
      items: touristBottomNavItems,
      tabOfBranch: _tabOfBranch,
      fullScreenTabs: const {navMessagesTabIndex: AppRoutes.messages},
    );
  }
}

/// The Provider tabs: Dashboard, Offers and Calendar keep their own
/// history; "Пораки" and "Профил" open full screen, as before.
class ProviderShell extends StatelessWidget {
  const ProviderShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabOfBranch = [0, 1, 2];

  @override
  Widget build(BuildContext context) {
    return _TabsScaffold(
      navigationShell: navigationShell,
      items: providerBottomNavItems,
      tabOfBranch: _tabOfBranch,
      fullScreenTabs: const {
        navMessagesTabIndex: AppRoutes.messages,
        4: AppRoutes.providerProfile,
      },
    );
  }
}

class _TabsScaffold extends StatefulWidget {
  const _TabsScaffold({
    required this.navigationShell,
    required this.items,
    required this.tabOfBranch,
    required this.fullScreenTabs,
  });

  final StatefulNavigationShell navigationShell;
  final List<BottomNavItem> items;
  final List<int> tabOfBranch;

  /// Nav bar positions that open a route full screen instead of a tab.
  final Map<int, String> fullScreenTabs;

  @override
  State<_TabsScaffold> createState() => _TabsScaffoldState();
}

class _TabsScaffoldState extends State<_TabsScaffold> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;
  List<int> get tabOfBranch => widget.tabOfBranch;

  @override
  void initState() {
    super.initState();
    // For the Messages badge; the chat list reloads them when opened.
    context.read<ChatBloc>().add(const ChatConversationsRequested());
  }

  void _handleTap(BuildContext context, int tab) {
    final fullScreenRoute = widget.fullScreenTabs[tab];
    if (fullScreenRoute != null) {
      context.push(fullScreenRoute);
      return;
    }
    final branch = tabOfBranch.indexOf(tab);
    navigationShell.goBranch(
      branch,
      // Re-tapping the current tab returns to its first screen.
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // The Messages tab shows the shared unread-messages badge.
      bottomNavigationBar: BlocSelector<ChatBloc, ChatState, int>(
        selector: (state) => state.totalUnreadMessages,
        builder: (context, unreadCount) {
          return BottomNavBar(
            items: widget.items,
            selectedIndex: tabOfBranch[navigationShell.currentIndex],
            badgeCounts: unreadCount > 0
                ? {navMessagesTabIndex: unreadCount}
                : const {},
            onTap: (tab) => _handleTap(context, tab),
          );
        },
      ),
    );
  }
}
