import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/countdown_provider.dart';
import '../providers/hive_provider.dart';
import '../providers/monitor_provider.dart';
import '../providers/review_start_provider.dart';
import '../providers/widget_config_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewStart = ref.watch(reviewStartProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spacing),
        children: [
          _buildItem(
            icon: Icons.calendar_month_outlined,
            title: 'Review Start Date',
            subtitle: reviewStart != null
                ? AppDateUtils.formatDate(reviewStart.startDate)
                : 'Not set',
            onTap: () => context.push('/review-start'),
          ),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.widgets_outlined,
            title: 'Widget Preview',
            subtitle: 'Configure your home screen widget',
            onTap: () => context.push('/widget-preview'),
          ),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.travel_explore_outlined,
            title: 'School Monitoring',
            subtitle: 'Manage notice sources and hits',
            onTap: () => context.push('/monitor'),
          ),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.info_outline,
            title: 'About Due',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Due',
                applicationVersion: '1.0.0',
                applicationLegalese: 'A minimal exam countdown app.',
              );
            },
          ),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.delete_sweep_outlined,
            title: 'Clear All Data',
            subtitle: 'Remove all countdowns and settings',
            isDestructive: true,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(hiveServiceProvider).clearAll();
                ref.invalidate(countdownListProvider);
                ref.invalidate(reviewStartProvider);
                ref.invalidate(widgetConfigProvider);
                ref.invalidate(monitorSourceListProvider);
                ref.invalidate(monitorHitListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final textColor = isDestructive ? Colors.red : AppTokens.textPrimary;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.7)
                      : AppTokens.textSecondary,
                ))
            : null,
        trailing:
            const Icon(Icons.chevron_right, color: AppTokens.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
