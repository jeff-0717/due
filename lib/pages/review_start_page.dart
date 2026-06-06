import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/review_start_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';

class ReviewStartPage extends ConsumerStatefulWidget {
  const ReviewStartPage({super.key});

  @override
  ConsumerState<ReviewStartPage> createState() => _ReviewStartPageState();
}

class _ReviewStartPageState extends ConsumerState<ReviewStartPage> {
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(reviewStartProvider);
    _startDate = existing?.startDate ??
        DateTime.now().subtract(const Duration(days: 30));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save() async {
    await ref.read(reviewStartProvider.notifier).set(_startDate);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('Review Start Date'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When did you start reviewing?',
              style: TextStyle(
                fontSize: AppTokens.fontSizeBody,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTokens.spacing),
                decoration: BoxDecoration(
                  color: AppTokens.card,
                  borderRadius: BorderRadius.circular(AppTokens.radius),
                  border: Border.all(color: AppTokens.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: AppTokens.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      AppDateUtils.formatDate(_startDate),
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeBody,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
