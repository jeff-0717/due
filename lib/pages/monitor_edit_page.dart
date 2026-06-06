import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/monitor_source.dart';
import '../providers/monitor_provider.dart';
import '../theme/app_tokens.dart';

class MonitorEditPage extends ConsumerStatefulWidget {
  final String? id;

  const MonitorEditPage({super.key, this.id});

  @override
  ConsumerState<MonitorEditPage> createState() => _MonitorEditPageState();
}

class _MonitorEditPageState extends ConsumerState<MonitorEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _schoolController;
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _keywordsController;
  MonitorSourceType _sourceType = MonitorSourceType.rss;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.id != null
        ? ref.read(monitorRepositoryProvider).getSource(widget.id!)
        : null;
    _schoolController = TextEditingController(text: existing?.schoolName ?? '');
    _nameController = TextEditingController(text: existing?.sourceName ?? '');
    _urlController = TextEditingController(text: existing?.url ?? '');
    _keywordsController =
        TextEditingController(text: existing?.keywords.join(', ') ?? '');
    _sourceType = existing?.sourceType ?? MonitorSourceType.rss;
    _isEnabled = existing?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _nameController.dispose();
    _urlController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: Text(widget.id == null ? 'Add Monitor Source' : 'Edit Monitor Source'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.spacing),
          children: [
            TextFormField(
              controller: _schoolController,
              decoration: const InputDecoration(labelText: 'School name'),
              validator: _required,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Source name'),
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
              keyboardType: TextInputType.url,
              validator: (value) {
                final uri = Uri.tryParse(value ?? '');
                if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                  return 'Enter a valid URL';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _keywordsController,
              decoration: const InputDecoration(labelText: 'Keywords'),
              validator: (value) =>
                  _keywords(value).isEmpty ? 'Enter at least one keyword' : null,
            ),
            const SizedBox(height: 12),
            SegmentedButton<MonitorSourceType>(
              segments: const [
                ButtonSegment(value: MonitorSourceType.rss, label: Text('RSS')),
                ButtonSegment(
                  value: MonitorSourceType.webPage,
                  label: Text('Web Page'),
                ),
              ],
              selected: {_sourceType},
              onSelectionChanged: (value) {
                setState(() => _sourceType = value.single);
              },
            ),
            SwitchListTile(
              title: const Text('Enabled'),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  List<String> _keywords(String? value) {
    return (value ?? '')
        .split(RegExp(r'[,，\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(monitorSourceListProvider.notifier);
    if (widget.id == null) {
      await notifier.add(
        schoolName: _schoolController.text.trim(),
        sourceName: _nameController.text.trim(),
        url: _urlController.text.trim(),
        sourceType: _sourceType,
        keywords: _keywords(_keywordsController.text),
        isEnabled: _isEnabled,
      );
    } else {
      await notifier.update(
        id: widget.id!,
        schoolName: _schoolController.text.trim(),
        sourceName: _nameController.text.trim(),
        url: _urlController.text.trim(),
        sourceType: _sourceType,
        keywords: _keywords(_keywordsController.text),
        isEnabled: _isEnabled,
      );
    }
    if (mounted) context.pop();
  }
}
