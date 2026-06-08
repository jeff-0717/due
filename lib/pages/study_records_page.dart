import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class StudyRecordsPage extends StatelessWidget {
  const StudyRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: const Text('学习记录'),
      ),
      body: const Center(
        child: Text('暂无学习记录'),
      ),
    );
  }
}
