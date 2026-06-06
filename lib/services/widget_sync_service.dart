import 'package:home_widget/home_widget.dart';
import '../models/countdown.dart';
import '../utils/app_date_utils.dart';

class WidgetSyncService {
  Future<void> syncCountdown(Countdown countdown) async {
    final daysLeft =
        AppDateUtils.daysUntil(countdown.targetDate, countdown.repeatType);
    final nextTarget = AppDateUtils.resolveNextTargetDate(
        countdown.targetDate, countdown.repeatType);

    await HomeWidget.saveWidgetData<String>('title', countdown.title);
    await HomeWidget.saveWidgetData<int>('daysLeft', daysLeft);
    await HomeWidget.saveWidgetData<String>(
        'targetDate', AppDateUtils.formatDate(nextTarget));
    await HomeWidget.saveWidgetData<String>('color', countdown.color);
    await HomeWidget.saveWidgetData<String>('icon', countdown.icon);

    await HomeWidget.updateWidget(
      androidName: 'DueWidgetProvider',
      iOSName: 'DueWidget',
    );
  }

  Future<void> syncReviewDays(int reviewDays) async {
    await HomeWidget.saveWidgetData<int>('reviewDays', reviewDays);
    await HomeWidget.updateWidget(
      androidName: 'DueWidgetProvider',
      iOSName: 'DueWidget',
    );
  }
}
