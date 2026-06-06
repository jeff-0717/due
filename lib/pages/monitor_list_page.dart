import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/monitor_source.dart';
import '../providers/monitor_provider.dart';
import '../services/monitor_check_service.dart';
import '../theme/app_tokens.dart';

class MonitorListPage extends ConsumerWidget {
  const MonitorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(monitorSourceListProvider);
    final checkStates = ref.watch(monitorCheckStateProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('院校信息监控'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/monitor/edit'),
          ),
        ],
      ),
      body: sources.isEmpty
          ? const Center(child: Text('暂无监控源'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spacing),
              itemCount: sources.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final source = sources[index];
                final state = checkStates[source.id];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      source.sourceType == MonitorSourceType.rss
                          ? Icons.rss_feed
                          : Icons.language,
                    ),
                    title: Text(source.schoolName),
                    subtitle: Text(
                      _subtitle(source, state),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SizedBox(
                      width: 144,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: '立即检查',
                            icon: const Icon(Icons.refresh),
                            onPressed: source.isEnabled
                                ? () async {
                                    final result = await ref
                                        .read(monitorCheckStateProvider.notifier)
                                        .check(source.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(_resultText(result)),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                          ),
                          IconButton(
                            tooltip: '命中记录',
                            icon: const Icon(Icons.article_outlined),
                            onPressed: () =>
                                context.push('/monitor/${source.id}/hits'),
                          ),
                          IconButton(
                            tooltip: '编辑',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                context.push('/monitor/edit/${source.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    final lastChecked = source.lastCheckedAt == null
        ? '尚未检查'
        : '上次检查 ${source.lastCheckedAt}';
    final keywords = source.keywords.join(', ');
    final liveState = state == null ? '' : ' - ${_statusText(state.status)}';
    return '$lastChecked - $keywords$liveState';
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
}
