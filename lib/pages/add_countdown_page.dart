import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/countdown_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/color_picker_row.dart';
import '../widgets/icon_picker_row.dart';

class AddCountdownPage extends ConsumerStatefulWidget {
  const AddCountdownPage({super.key});

  @override
  ConsumerState<AddCountdownPage> createState() => _AddCountdownPageState();
}

class _AddCountdownPageState extends ConsumerState<AddCountdownPage> {
  final _titleController = TextEditingController();
  late DateTime _targetDate;
  String _repeatType = 'once';
  String _color = ColorPickerRow.colors.first;
  String _icon = IconPickerRow.icons.first;
  String? _titleError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '请输入标题');
      return;
    }

    setState(() {
      _isSaving = true;
      _titleError = null;
    });

    try {
      await ref.read(countdownListProvider.notifier).add(
            title: title,
            targetDate: _targetDate,
            repeatType: _repeatType,
            color: _color,
            icon: _icon,
          );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('添加倒计时'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '例如：期末考试',
              ).copyWith(errorText: _titleError),
            ),
            const SizedBox(height: 24),
            const Text(
              '目标日期',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
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
                      AppDateUtils.formatDate(_targetDate),
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeBody,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '重复',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'once', label: Text('一次')),
                ButtonSegment(value: 'yearly', label: Text('每年')),
              ],
              selected: {_repeatType},
              onSelectionChanged: (v) => setState(() => _repeatType = v.first),
            ),
            const SizedBox(height: 24),
            const Text(
              '颜色',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ColorPickerRow(
              selectedColor: _color,
              onChanged: (c) => setState(() => _color = c),
            ),
            const SizedBox(height: 24),
            const Text(
              '图标',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            IconPickerRow(
              selectedIcon: _icon,
              onChanged: (i) => setState(() => _icon = i),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? '保存中...' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
