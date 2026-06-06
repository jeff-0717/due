import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/add_countdown_page.dart';
import '../pages/edit_countdown_page.dart';
import '../pages/review_start_page.dart';
import '../pages/widget_preview_page.dart';
import '../pages/settings_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add',
        name: 'add',
        builder: (context, state) => const AddCountdownPage(),
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'edit',
        builder: (context, state) => EditCountdownPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/review-start',
        name: 'reviewStart',
        builder: (context, state) => const ReviewStartPage(),
      ),
      GoRoute(
        path: '/widget-preview',
        name: 'widgetPreview',
        builder: (context, state) => const WidgetPreviewPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
