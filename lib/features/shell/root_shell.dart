import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../add/add_entry_sheet.dart';
import '../community/community_tab.dart';
import '../history/history_tab.dart';
import '../home/home_tab.dart';
import '../profile/profile_tab.dart';

/// Bottom-nav scaffold hosting Home, Community, Add (modal), History, Profile.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});
  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeTab(),
    CommunityTab(),
    SizedBox.shrink(), // Add tab: handled via modal, never selected
    HistoryTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _pages[_index],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 2) {
            showAddEntrySheet(context);
            return;
          }
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l.navCommunity,
          ),
          NavigationDestination(
            icon: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: scheme.onPrimary, size: 22),
            ),
            label: l.navAdd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            selectedIcon: const Icon(Icons.history),
            label: l.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}
