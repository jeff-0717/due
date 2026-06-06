import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/countdown.dart';
import '../providers/countdown_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/app_date_utils.dart';
import '../widgets/color_picker_row.dart';
import '../widgets/icon_picker_row.dart';

class EditCountdownPage extends ConsumerStatefulWidget {
  final String id;
  const EditCountdownPage({super.key, required this.id});

  @override
  ConsumerState<EditCountdownPage> createState() => _EditCountdownPageState();
}

class _EditCountdownPageState extends ConsumerState<EditCountdownPage> {
  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now();
  String _repeatType = 'once';
  String _color = ColorPickerRow.colors.first;
  String _icon = IconPickerRow.icons.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _load() {
    final countdowns = ref.read(countdownListProvider);
    final item = countdowns.where((c) => c.id == widget.id).firstOrNull;
    if (item != null) {
      setState(() {
        _titleController.text = item.title;
        _targetDate = item.targetDate;
        _repeatType = item.repeatType.name;
        _color = item.color;
        _icon = item.icon;
      });
    }
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
    if (_titleController.text.trim().isEmpty) return;
    await ref.read(countdownListProvider.notifier).update(
          id: widget.id,
          title: _titleController.text.trim(),
          targetDate: _targetDate,
          repeatType: _repeatType,
          color: _color,
          icon: _icon,
        );
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(countdownListProvider.notifier).delete(widget.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('Edit Countdown'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Final Exam',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Target Date',
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
              'Repeat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'once', label: Text('Once')),
                ButtonSegment(value: 'yearly', label: Text('Yearly')),
              ],
              selected: {_repeatType},
              onSelectionChanged: (v) => setState(() => _repeatType = v.first),
            ),
            const SizedBox(height: 24),
            const Text(
              'Color',
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
              'Icon',
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
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
