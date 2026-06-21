package com.example.due

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DueWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val title = widgetData.getString("title", null) ?: "Due"
            val targetDate = widgetData.getString("targetDate", null) ?: "请选择倒计时"
            val daysLeft = widgetData.getInt("daysLeft", 0)
            val accentColor = parseColor(widgetData.getString("color", null))

            val views = RemoteViews(context.packageName, R.layout.due_widget).apply {
                setTextViewText(R.id.widget_title, "${title}还剩")
                setTextViewText(R.id.widget_subtitle, title)
                setTextViewText(R.id.widget_target_date, targetDate)
                setTextViewText(R.id.widget_days_left, daysLeft.toString())
                setTextColor(R.id.widget_days_left, accentColor)
                setTextColor(R.id.widget_target_date, accentColor)

                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, launchIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun parseColor(value: String?): Int {
        return try {
            Color.parseColor(value ?: "#2563EB")
        } catch (_: IllegalArgumentException) {
            Color.parseColor("#2563EB")
        }
    }
}
