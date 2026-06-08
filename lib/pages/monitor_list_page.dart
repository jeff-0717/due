import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/monitor_source.dart';
import '../providers/monitor_provider.dart';
import '../services/monitor_check_service.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_section.dart';
import '../widgets/empty_state.dart';

class MonitorListPage extends ConsumerWidget {
  const MonitorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(monitorSourceListProvider);
    final checkStates = ref.watch(monitorCheckStateProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('院校动态'),
        actions: [
          IconButton(
            tooltip: '添加监控源',
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/monitor/edit'),
          ),
        ],
      ),
      body: sources.isEmpty
          ? EmptyState(
              message: '暂无监控源',
              actionLabel: '添加院校来源',
              onAction: () => context.push('/monitor/edit'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                AppTokens.spacing,
                AppTokens.pagePadding,
                96,
              ),
              itemCount: sources.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTokens.spacingSm),
              itemBuilder: (context, index) {
                final source = sources[index];
                final state = checkStates[source.id];
                return _MonitorSourceCard(
                  source: source,
                  state: state,
                  subtitle: _subtitle(source, state),
                  statusText: _statusLabel(source, state),
                  statusStyle: _statusStyle(source, state),
                  onRefresh: source.isEnabled
                      ? () async {
                          final result = await ref
                              .read(monitorCheckStateProvider.notifier)
                              .check(source.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_resultText(result))),
                            );
                          }
                        }
                      : null,
                  onHits: () => context.push('/monitor/${source.id}/hits'),
                  onEdit: () => context.push('/monitor/edit/${source.id}'),
                  onDelete: () => _confirmDelete(context, ref, source),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/monitor/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _subtitle(MonitorSource source, MonitorCheckResult? state) {
    final lastChecked =
        source.lastCheckedAt == null ? '尚未检查' : '上次检查 ${source.lastCheckedAt}';
    final keywords = source.keywords.join(', ');
    final liveState = state == null ? '' : ' - ${_statusText(state.status)}';
    return '$lastChecked - $keywords$liveState';
  }

  String _statusLabel(MonitorSource source, MonitorCheckResult? state) {
    if (!source.isEnabled) return '已停用';
    if (state == null) return '运行中';
    return _statusText(state.status);
  }

  _StatusStyle _statusStyle(MonitorSource source, MonitorCheckResult? state) {
    if (!source.isEnabled) {
      return const _StatusStyle(
        foreground: AppTokens.textSecondary,
        background: AppTokens.surfaceLow,
        icon: Icons.pause_circle_outline,
      );
    }
    if (state == null) {
      return const _StatusStyle(
        foreground: AppTokens.primaryDark,
        background: AppTokens.successSoft,
        icon: Icons.check_circle_outline,
      );
    }
    switch (state.status) {
      case MonitorCheckStatus.newHits:
        return const _StatusStyle(
          foreground: AppTokens.primaryDark,
          background: AppTokens.successSoft,
          icon: Icons.notifications_active_outlined,
        );
      case MonitorCheckStatus.noNewHits:
        return const _StatusStyle(
          foreground: AppTokens.secondary,
          background: AppTokens.surfaceLow,
          icon: Icons.done_all_outlined,
        );
      case MonitorCheckStatus.failure:
        return const _StatusStyle(
          foreground: AppTokens.danger,
          background: AppTokens.dangerSoft,
          icon: Icons.error_outline,
        );
    }
  }

  String _resultText(MonitorCheckResult result) {
    if (result.errorMessage != null) return '检查失败：${result.errorMessage}';
    if (result.newHitCount == 0) return '没有新的命中';
    return '发现 ${result.newHitCount} 条新命中';
  }

  String _statusText(MonitorCheckStatus status) {
    switch (status) {
      case MonitorCheckStatus.newHits:
        return '有新命中';
      case MonitorCheckStatus.noNewHits:
        return '无新命中';
      case MonitorCheckStatus.failure:
        return '检查失败';
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonitorSource source,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除监控源'),
        content: Text('确定删除“${source.schoolName}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(monitorSourceListProvider.notifier).delete(source.id);
  }
}

class _MonitorSourceCard extends StatelessWidget {
  final MonitorSource source;
  final MonitorCheckResult? state;
  final String subtitle;
  final String statusText;
  final _StatusStyle statusStyle;
  final VoidCallback? onRefresh;
  final VoidCallback onHits;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MonitorSourceCard({
    required this.source,
    required this.state,
    required this.subtitle,
    required this.statusText,
    required this.statusStyle,
    required this.onRefresh,
    required this.onHits,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTokens.surfaceLow,
                    borderRadius: BorderRadius.circular(AppTokens.radius),
                    border: Border.all(color: AppTokens.border),
                  ),
                  child: Icon(
                    source.sourceType == MonitorSourceType.rss
                        ? Icons.rss_feed
                        : Icons.language,
                    size: 20,
                    color: AppTokens.primary,
                  ),
                ),
                const SizedBox(width: AppTokens.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              source.schoolName,
                              style: const TextStyle(
                                color: AppTokens.textPrimary,
                                fontSize: AppTokens.fontSizeBodyLarge,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          AppStatusChip(
                            label: statusText,
                            foreground: statusStyle.foreground,
                            background: statusStyle.background,
                            icon: statusStyle.icon,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.spacingXs),
                      Text(
                        source.sourceName.isEmpty
                            ? source.url
                            : source.sourceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTokens.textSecondary,
                          fontSize: AppTokens.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTokens.textSecondary,
                fontSize: AppTokens.fontSizeSmall,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Wrap(
              spacing: AppTokens.spacingSm,
              runSpacing: AppTokens.spacingSm,
              children: source.keywords
                  .take(4)
                  .map((keyword) => _KeywordChip(label: keyword))
                  .toList(),
            ),
            const Divider(height: AppTokens.spacingLg, color: AppTokens.border),
            Row(
              children: [
                _ToolButton(
                  icon: Icons.refresh,
                  label: '检查',
                  onPressed: onRefresh,
                ),
                _ToolButton(
                  icon: Icons.article_outlined,
                  label: '记录',
                  onPressed: onHits,
                ),
                const Spacer(),
                IconButton(
                  tooltip: '编辑',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: '删除',
                  icon: const Icon(Icons.delete_outline),
                  color: AppTokens.danger,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;

  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.surfaceLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTokens.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _StatusStyle {
  final Color foreground;
  final Color background;
  final IconData icon;

  const _StatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });
}
