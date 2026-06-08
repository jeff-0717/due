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
import '../widgets/app_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewStart = ref.watch(reviewStartProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pagePadding,
          AppTokens.spacing,
          AppTokens.pagePadding,
          AppTokens.spacing,
        ),
        children: [
          AppSection(
            title: '备考设置',
            subtitle: '和学习节奏直接相关的项目',
            padding: EdgeInsets.zero,
            child: _SettingsGroup(
              children: [
                _buildItem(
                  icon: Icons.calendar_month_outlined,
                  title: '复习开始日期',
                  subtitle: reviewStart != null
                      ? AppDateUtils.formatDate(reviewStart.startDate)
                      : '未设置',
                  onTap: () => context.push('/review-start'),
                ),
                _buildItem(
                  icon: Icons.widgets_outlined,
                  title: '桌面组件预览',
                  subtitle: '配置桌面倒计时组件',
                  onTap: () => context.push('/widget-preview'),
                ),
                _buildItem(
                  icon: Icons.travel_explore_outlined,
                  title: '院校信息监控',
                  subtitle: '管理公告来源和命中记录',
                  onTap: () => context.push('/monitor'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spacing),
          AppSection(
            title: '应用',
            padding: EdgeInsets.zero,
            child: _SettingsGroup(
              children: [
                _buildItem(
                  icon: Icons.info_outline,
                  title: '关于 Due',
                  subtitle: '版本 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Due',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '一款极简考试倒计时应用。',
                    );
                  },
                ),
                _buildItem(
                  icon: Icons.delete_sweep_outlined,
                  title: '清空全部数据',
                  subtitle: '删除所有倒计时和设置',
                  isDestructive: true,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('清空全部数据'),
                        content: const Text('此操作无法撤销。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('清空',
                                style: TextStyle(color: AppTokens.danger)),
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
                          const SnackBar(content: Text('数据已清空')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
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
    final textColor = isDestructive ? AppTokens.danger : AppTokens.textPrimary;
    final iconColor = isDestructive ? AppTokens.danger : AppTokens.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spacing,
        vertical: AppTokens.spacingXs,
      ),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDestructive ? AppTokens.dangerSoft : AppTokens.successSoft,
          borderRadius: BorderRadius.circular(AppTokens.radius),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: AppTokens.fontSizeBody,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDestructive
                    ? AppTokens.danger.withValues(alpha: 0.72)
                    : AppTokens.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppTokens.textMuted),
      onTap: onTap,
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: 1,
                indent: 70,
                color: AppTokens.border,
              ),
          ],
        ],
      ),
    );
  }
}
