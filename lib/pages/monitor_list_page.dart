import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/monitor_source.dart';
import '../providers/monitor_provider.dart';
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
        title: const Text('School Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/monitor/edit'),
          ),
        ],
      ),
      body: sources.isEmpty
          ? const Center(child: Text('No monitor sources yet'))
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
                    subtitle: Text(_subtitle(source, state)),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Check now',
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
                          tooltip: 'Hits',
                          icon: const Icon(Icons.article_outlined),
                          onPressed: () => context.push('/monitor/${source.id}/hits'),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.push('/monitor/edit/${source.id}'),
                        ),
                      ],
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

  String _subtitle(MonitorSource source, dynamic state) {
    final lastChecked = source.lastCheckedAt == null
        ? 'Never checked'
        : 'Last checked ${source.lastCheckedAt}';
    final keywords = source.keywords.join(', ');
    final liveState = state == null ? '' : ' · ${state.status.name}';
    return '$lastChecked · $keywords$liveState';
  }

  String _resultText(dynamic result) {
    if (result.errorMessage != null) return 'Check failed: ${result.errorMessage}';
    if (result.newHitCount == 0) return 'No new hits';
    return 'Found ${result.newHitCount} new hit(s)';
  }
}
