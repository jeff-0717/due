import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monitor_hit.dart';
import '../providers/monitor_provider.dart';
import '../services/monitor_link_opener.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class MonitorHitsPage extends ConsumerStatefulWidget {
  final String sourceId;

  const MonitorHitsPage({super.key, required this.sourceId});

  @override
  ConsumerState<MonitorHitsPage> createState() => _MonitorHitsPageState();
}

class _MonitorHitsPageState extends ConsumerState<MonitorHitsPage> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = ref
        .watch(monitorSourceListProvider)
        .where((item) => item.id == widget.sourceId)
        .firstOrNull;
    final hits =
        ref.watch(monitorHitListProvider.notifier).forSource(widget.sourceId);
    final filteredHits = _filterHits(hits, _query);
    final opener = ref.watch(monitorLinkOpenerProvider);

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(title: Text(source?.schoolName ?? '命中记录')),
      body: hits.isEmpty
          ? const Center(child: Text('暂无命中记录'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spacing),
              itemCount: filteredHits.isEmpty ? 2 : filteredHits.length + 1,
              separatorBuilder: (_, index) => index == 0
                  ? const SizedBox(height: 12)
                  : const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SearchField(
                    controller: _queryController,
                    onChanged: _updateQuery,
                  );
                }
                if (filteredHits.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: Text('暂无匹配记录')),
                  );
                }
                final hit = filteredHits[index - 1];
                return _HitCard(hit: hit, opener: opener);
              },
            ),
    );
  }

  void _updateQuery(String value) {
    setState(() => _query = value.trim().toLowerCase());
  }

  List<MonitorHit> _filterHits(List<MonitorHit> hits, String query) {
    if (query.isEmpty) return hits;
    return hits.where((hit) {
      final haystack = [
        hit.title,
        hit.summary,
        ...hit.matchedKeywords,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: '搜索标题、摘要或关键词',
      ),
    );
  }
}

class _HitCard extends StatelessWidget {
  final MonitorHit hit;
  final MonitorLinkOpener opener;

  const _HitCard({
    required this.hit,
    required this.opener,
  });

  @override
  Widget build(BuildContext context) {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('无法打开原文链接')),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
