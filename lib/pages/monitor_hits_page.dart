import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monitor_hit.dart';
import '../providers/monitor_provider.dart';
import '../services/monitor_link_opener.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/app_section.dart';
import '../widgets/empty_state.dart';

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
      backgroundColor: AppTokens.homeBackground,
      appBar: AppBar(
        title: Text(source?.schoolName ?? '命中记录'),
        backgroundColor: AppTokens.homeBackground,
        foregroundColor: AppTokens.homeSageDark,
        elevation: 0,
      ),
      body: hits.isEmpty
          ? const EmptyState(
              message: '暂无命中记录',
              actionLabel: '等待下一次检查',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                AppTokens.spacing,
                AppTokens.pagePadding,
                96,
              ),
              itemCount: filteredHits.isEmpty ? 2 : filteredHits.length + 1,
              separatorBuilder: (_, index) => index == 0
                  ? const SizedBox(height: AppTokens.spacing)
                  : const SizedBox(height: AppTokens.spacingSm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AppSection(
                    title: '命中记录',
                    subtitle: '按标题、摘要或关键词快速过滤公告',
                    padding: EdgeInsets.zero,
                    child: _SearchField(
                      controller: _queryController,
                      onChanged: _updateQuery,
                    ),
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
        prefixIcon: Icon(Icons.search, size: 20),
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
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppStatusChip(
                  label: '新公告',
                  icon: Icons.article_outlined,
                ),
                const Spacer(),
                if (hit.publishedAt != null)
                  Text(
                    AppDateUtils.formatDate(hit.publishedAt!),
                    style: const TextStyle(
                      fontSize: AppTokens.fontSizeSmall,
                      color: AppTokens.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.spacing),
            Text(
              hit.title,
              style: const TextStyle(
                fontSize: AppTokens.fontSizeBodyLarge,
                fontWeight: FontWeight.w700,
                color: AppTokens.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Wrap(
              spacing: AppTokens.spacingSm,
              runSpacing: AppTokens.spacingSm,
              children: [
                Text(
                  '命中关键词：${hit.matchedKeywords.join('、')}',
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeSmall,
                    color: AppTokens.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (hit.summary.trim().isNotEmpty) ...[
              const SizedBox(height: AppTokens.spacingSm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTokens.spacing),
                decoration: BoxDecoration(
                  color: AppTokens.surfaceLow,
                  borderRadius: BorderRadius.circular(AppTokens.radius),
                  border: Border.all(color: AppTokens.border),
                ),
                child: Text(
                  hit.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppTokens.fontSizeSmall,
                    color: AppTokens.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTokens.spacingSm),
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
