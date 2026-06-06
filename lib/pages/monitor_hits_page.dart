import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitor_provider.dart';
import '../services/monitor_link_opener.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class MonitorHitsPage extends ConsumerWidget {
  final String sourceId;

  const MonitorHitsPage({super.key, required this.sourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref
        .watch(monitorSourceListProvider)
        .where((item) => item.id == sourceId)
        .firstOrNull;
    final hits = ref.watch(monitorHitListProvider.notifier).forSource(sourceId);
    final opener = ref.watch(monitorLinkOpenerProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(title: Text(source?.schoolName ?? '命中记录')),
      body: hits.isEmpty
          ? const Center(child: Text('暂无命中记录'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spacing),
              itemCount: hits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final hit = hits[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hit.title,
                          style: const TextStyle(
                            fontSize: AppTokens.fontSizeBody,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '命中关键词：${hit.matchedKeywords.join('、')}',
                          style: const TextStyle(
                            fontSize: AppTokens.fontSizeSmall,
                            color: AppTokens.primary,
                          ),
                        ),
                        if (hit.publishedAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '发布日期：${AppDateUtils.formatDate(hit.publishedAt!)}',
                            style: const TextStyle(
                              fontSize: AppTokens.fontSizeSmall,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                        ],
                        if (hit.summary.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            hit.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppTokens.fontSizeSmall,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('打开原文'),
                            onPressed: hit.link.trim().isEmpty
                                ? null
                                : () async {
                                    final opened = await opener.open(hit.link);
                                    if (!opened && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('无法打开原文链接'),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
