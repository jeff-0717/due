import 'package:home_widget/home_widget.dart';
import '../models/countdown.dart';
import '../utils/app_date_utils.dart';

class WidgetSyncService {
  static const appGroupId = 'group.com.example.due';
  static const androidWidgetName = 'DueWidgetProvider';
  static const iOSWidgetName = 'DueWidget';
  static const titleKey = 'title';
  static const daysLeftKey = 'daysLeft';
  static const targetDateKey = 'targetDate';
  static const colorKey = 'color';
  static const iconKey = 'icon';
  static const reviewDaysKey = 'reviewDays';

  static Map<String, Object> buildCountdownData(Countdown countdown) {
    final daysLeft =
        AppDateUtils.daysUntil(countdown.targetDate, countdown.repeatType);
    final nextTarget = AppDateUtils.resolveNextTargetDate(
        countdown.targetDate, countdown.repeatType);

    return {
      titleKey: countdown.title,
      daysLeftKey: daysLeft,
      targetDateKey: AppDateUtils.formatDate(nextTarget),
      colorKey: countdown.color,
      iconKey: countdown.icon,
    };
  }

  Future<void> syncCountdown(Countdown countdown) async {
    final data = buildCountdownData(countdown);

    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.saveWidgetData<String>(titleKey, data[titleKey] as String);
    await HomeWidget.saveWidgetData<int>(daysLeftKey, data[daysLeftKey] as int);
    await HomeWidget.saveWidgetData<String>(
        targetDateKey, data[targetDateKey] as String);
    await HomeWidget.saveWidgetData<String>(colorKey, data[colorKey] as String);
    await HomeWidget.saveWidgetData<String>(iconKey, data[iconKey] as String);

    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }

  Future<void> syncReviewDays(int reviewDays) async {
    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.saveWidgetData<int>(reviewDaysKey, reviewDays);
    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}
