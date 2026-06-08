import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShellPage extends StatelessWidget {
  final Widget child;
  final String location;

  const AppShellPage({
    super.key,
    required this.child,
    required this.location,
  });

  static const _tabs = [
    _ShellTab(
      label: '首页',
      path: '/',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _ShellTab(
      label: '院校',
      path: '/monitor',
      icon: Icons.travel_explore_outlined,
      selectedIcon: Icons.travel_explore,
    ),
    _ShellTab(
      label: '记录',
      path: '/record',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
    ),
    _ShellTab(
      label: '设置',
      path: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  int _selectedIndex(String path) {
    if (path.startsWith('/monitor')) return 1;
    if (path.startsWith('/record')) return 2;
    if (path.startsWith('/settings')) return 3;
    return 0;
  }
}

class _ShellTab {
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  const _ShellTab({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });
}
