import 'dart:io';

import 'package:due/models/countdown.dart';
import 'package:due/services/widget_sync_service.dart';
import 'package:due/utils/app_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('widget sync contract exposes stable platform identifiers', () {
    expect(WidgetSyncService.androidWidgetName, 'DueWidgetProvider');
    expect(WidgetSyncService.iOSWidgetName, 'DueWidget');
    expect(WidgetSyncService.appGroupId, 'group.com.example.due');
  });

  test('buildCountdownData matches shared widget keys', () {
    final countdown = _countdown();
    final data = WidgetSyncService.buildCountdownData(countdown);

    expect(data[WidgetSyncService.titleKey], 'Final Exam');
    expect(
        data[WidgetSyncService.daysLeftKey],
        AppDateUtils.daysUntil(
          countdown.targetDate,
          countdown.repeatType,
        ));
    expect(data[WidgetSyncService.targetDateKey], isA<String>());
    expect(data[WidgetSyncService.colorKey], '#2563EB');
    expect(data[WidgetSyncService.iconKey], 'E');
  });

  test('Android widget provider uses compact 2x2 launcher size', () async {
    final xml = await File('android/app/src/main/res/xml/due_widget_info.xml')
        .readAsString();

    expect(xml, contains('android:minWidth="110dp"'));
    expect(xml, contains('android:minHeight="110dp"'));
    expect(xml, contains('android:minResizeWidth="110dp"'));
    expect(xml, contains('android:minResizeHeight="110dp"'));
    expect(xml, contains('android:targetCellWidth="2"'));
    expect(xml, contains('android:targetCellHeight="2"'));
    expect(xml, contains('android:widgetCategory="home_screen"'));
  });

  test('Android widget layout uses RemoteViews-compatible primitives',
      () async {
    final xml = await File('android/app/src/main/res/layout/due_widget.xml')
        .readAsString();

    expect(xml, isNot(contains('<View')));
    expect(xml, contains('<LinearLayout'));
    expect(xml, contains('<TextView'));
    expect(xml, contains('android:orientation="vertical"'));
    expect(xml, contains('@+id/widget_subtitle'));
    expect(xml, isNot(contains('@+id/widget_accent')));
    expect(xml, contains('android:gravity="center"'));
  });

  test('Android widget background uses Todo-like soft card color', () async {
    final xml = await File(
            'android/app/src/main/res/drawable/due_widget_background.xml')
        .readAsString();

    expect(xml, contains('android:color="#F2F0FF"'));
    expect(xml, contains('android:radius="16dp"'));
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

  test('iOS widget source stays compatible with its deployment target',
      () async {
    final project =
        await File('ios/Runner.xcodeproj/project.pbxproj').readAsString();
    final widgetSource =
        await File('ios/DueWidget/DueWidget.swift').readAsString();

    expect(project, contains('IPHONEOS_DEPLOYMENT_TARGET = 14.0;'));
    expect(widgetSource, isNot(contains('.foregroundStyle')));
    expect(widgetSource, contains('widgetHostBackground()'));
  });

  test('iOS widget view uses matching compact centered card style', () async {
    final widgetSource =
        await File('ios/DueWidget/DueWidget.swift').readAsString();

    expect(widgetSource, contains('VStack(spacing: 10)'));
    expect(widgetSource, contains('font(.system(size: 46, weight: .bold))'));
    expect(widgetSource, contains('Color(red: 0.95, green: 0.94, blue: 1.0)'));
    expect(widgetSource,
        contains('frame(maxWidth: .infinity, maxHeight: .infinity)'));
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
