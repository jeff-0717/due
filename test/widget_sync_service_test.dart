import 'dart:io';

import 'package:due/models/countdown.dart';
import 'package:due/services/widget_sync_service.dart';
import 'package:due/utils/app_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCountdownData matches Android widget keys', () {
    final countdown = _countdown();
    final data = WidgetSyncService.buildCountdownData(countdown);

    expect(data['title'], 'Final Exam');
    expect(
        data['daysLeft'],
        AppDateUtils.daysUntil(
          countdown.targetDate,
          countdown.repeatType,
        ));
    expect(data['targetDate'], isA<String>());
    expect(data['color'], '#2563EB');
    expect(data['icon'], 'E');
  });

  test('Android widget provider uses launcher-friendly minimum size', () async {
    final xml = await File('android/app/src/main/res/xml/due_widget_info.xml')
        .readAsString();

    expect(xml, contains('android:minWidth="180dp"'));
    expect(xml, contains('android:minHeight="72dp"'));
    expect(xml, contains('android:minResizeWidth="180dp"'));
    expect(xml, contains('android:minResizeHeight="72dp"'));
    expect(xml, contains('android:targetCellWidth="3"'));
    expect(xml, contains('android:targetCellHeight="1"'));
    expect(xml, contains('android:widgetCategory="home_screen"'));
  });

  test('Android widget layout uses RemoteViews-compatible primitives',
      () async {
    final xml = await File('android/app/src/main/res/layout/due_widget.xml')
        .readAsString();

    expect(xml, isNot(contains('<View')));
    expect(xml, contains('<FrameLayout'));
    expect(xml, contains('<LinearLayout'));
    expect(xml, contains('<TextView'));
  });

  test('Android manifest registers the AppWidget receiver', () async {
    final manifest =
        await File('android/app/src/main/AndroidManifest.xml').readAsString();

    expect(manifest, contains('android:name=".DueWidgetProvider"'));
    expect(manifest, contains('android.appwidget.action.APPWIDGET_UPDATE'));
    expect(manifest, contains('android:name="android.appwidget.provider"'));
    expect(manifest, contains('android:resource="@xml/due_widget_info"'));
  });

  test('iOS widget extension is wired into the Xcode project', () async {
    final project =
        await File('ios/Runner.xcodeproj/project.pbxproj').readAsString();
    final widgetSource =
        await File('ios/DueWidget/DueWidget.swift').readAsString();
    final widgetInfo = await File('ios/DueWidget/Info.plist').readAsString();
    final runnerEntitlements =
        await File('ios/Runner/Runner.entitlements').readAsString();
    final widgetEntitlements =
        await File('ios/DueWidget/DueWidget.entitlements').readAsString();

    expect(project, contains('DueWidget.appex'));
    expect(project, contains('com.apple.product-type.app-extension'));
    expect(project, contains('PBXCopyFilesBuildPhase'));
    expect(project, contains('DueWidget.swift in Sources'));
    expect(widgetSource, contains('struct DueWidget: Widget'));
    expect(widgetSource, contains('kind = "DueWidget"'));
    expect(widgetInfo, contains('NSExtensionPointIdentifier'));
    expect(runnerEntitlements, contains('group.com.example.due'));
    expect(widgetEntitlements, contains('group.com.example.due'));
  });
}

Countdown _countdown() {
  final now = DateTime.now();
  return Countdown(
    id: 'exam',
    title: 'Final Exam',
    targetDate: now.add(const Duration(days: 12)),
    repeatType: RepeatType.once,
    color: '#2563EB',
    icon: 'E',
    createdAt: now,
    updatedAt: now,
  );
}
