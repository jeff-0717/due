import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitor_provider.dart';
import '../theme/app_tokens.dart';

class MonitorHitsPage extends ConsumerWidget {
  final String sourceId;

  const MonitorHitsPage({super.key, required this.sourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(monitorSourceListProvider).where((item) => item.id == sourceId).firstOrNull;
    final hits = ref.watch(monitorHitListProvider.notifier).forSource(sourceId);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(title: Text(source?.schoolName ?? 'Monitor Hits')),
      body: hits.isEmpty
          ? const Center(child: Text('No hits yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spacing),
              itemCount: hits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final hit = hits[index];
                return Card(
                  child: ListTile(
                    title: Text(hit.title),
                    subtitle: Text(
                      '${hit.matchedKeywords.join(', ')}\n${hit.summary}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Copy link',
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: hit.link));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
