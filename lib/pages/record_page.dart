import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('记录'),
        actions: [
          IconButton(
            tooltip: '学习记录',
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => context.push('/study-records'),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '45:00',
          style: TextStyle(
            color: AppTokens.textPrimary,
            fontSize: AppTokens.fontSizeLargeNumber,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
