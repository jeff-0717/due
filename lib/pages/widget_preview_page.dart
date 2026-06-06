import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/countdown_provider.dart';
import '../providers/widget_config_provider.dart';
import '../providers/widget_sync_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/widget_preview_card.dart';

class WidgetPreviewPage extends ConsumerWidget {
  const WidgetPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownListProvider);
    final config = ref.watch(widgetConfigProvider);
    final selectedId = config?.countdownId;
    final selected = countdowns.where((c) => c.id == selectedId).firstOrNull;

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('桌面组件预览'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '预览',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            WidgetPreviewCard(countdown: selected),
            const SizedBox(height: 24),
            const Text(
              '选择倒计时',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: countdowns.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无可用倒计时',
                        style: TextStyle(color: AppTokens.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: countdowns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = countdowns[index];
                        final isSelected = item.id == selectedId;
                        final color = Color(
                            int.parse(item.color.replaceFirst('#', '0xFF')));
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Text(item.icon,
                                    style: const TextStyle(fontSize: 20))),
                          ),
                          title: Text(item.title),
                          subtitle:
                              Text(AppDateUtils.formatDate(item.targetDate)),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppTokens.primary)
                              : null,
                          onTap: () {
                            ref
                                .read(widgetConfigProvider.notifier)
                                .set(item.id, 'default');
                          },
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () async {
                        final sync = ref.read(widgetSyncServiceProvider);
                        await sync.syncCountdown(selected);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '已同步，请回到桌面长按空白处添加 Due 倒计时组件',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('同步到桌面组件'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
