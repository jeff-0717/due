package com.example.due

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object FocusTimerNotifications {
    const val CHANNEL_ID = "due_focus_timer"
    const val NOTIFICATION_ID = 4501
    const val ACTION_PAUSE = "com.example.due.action.FOCUS_PAUSE"
    const val ACTION_RESUME = "com.example.due.action.FOCUS_RESUME"
    const val ACTION_FINISH = "com.example.due.action.FOCUS_FINISH"
    const val EXTRA_PLANNED_SECONDS = "plannedSeconds"
    const val EXTRA_REMAINING_SECONDS = "remainingSeconds"
    const val EXTRA_MODE = "mode"

    private var lastShownAtRealtime = 0L
    private var lastDisplaySeconds = 0
    private var lastMode = "fixed45"
    private var lastIsRunning = false

    fun show(
        context: Context,
        plannedSeconds: Int,
        remainingSeconds: Int,
        isRunning: Boolean,
        mode: String
    ) {
        ensureChannel(context)
        lastShownAtRealtime = SystemClock.elapsedRealtime()
        lastDisplaySeconds = remainingSeconds
        lastMode = mode
        lastIsRunning = isRunning

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val title = if (mode == "unlimited") {
            "\u4e13\u6ce8\u8ba1\u65f6"
        } else {
            "\u4e13\u6ce8\u8ba1\u65f6 ${plannedSeconds / 60} \u5206\u949f"
        }
        val contentText = if (isRunning) {
            "\u9501\u5c4f\u53ef\u6682\u505c\u6216\u7ed3\u675f"
        } else {
            "\u5df2\u6682\u505c\uff0c\u53ef\u7ee7\u7eed\u6216\u7ed3\u675f"
        }
        val now = SystemClock.elapsedRealtime()
        val chronometerAt = if (mode == "unlimited") {
            now - remainingSeconds.coerceAtLeast(0) * 1000L
        } else {
            now + remainingSeconds.coerceAtLeast(0) * 1000L
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle(title)
            .setContentText(contentText)
            .setContentIntent(contentIntent)
            .setOngoing(isRunning)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(chronometerAt)
            .setUsesChronometer(isRunning)
            .setChronometerCountDown(isRunning && mode != "unlimited")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        if (isRunning) {
            builder.addAction(
                android.R.drawable.ic_media_pause,
                "\u6682\u505c",
                actionIntent(context, ACTION_PAUSE, plannedSeconds, remainingSeconds, mode)
            )
        } else {
            builder.addAction(
                android.R.drawable.ic_media_play,
                "\u7ee7\u7eed",
                actionIntent(context, ACTION_RESUME, plannedSeconds, remainingSeconds, mode)
            )
        }
        builder.addAction(
            android.R.drawable.ic_menu_close_clear_cancel,
            "\u7ed3\u675f",
            actionIntent(context, ACTION_FINISH, plannedSeconds, remainingSeconds, mode)
        )

        try {
            NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, builder.build())
        } catch (_: SecurityException) {
            // Android 13+ may deny notifications until the user grants permission.
        }
    }

    fun cancel(context: Context) {
        lastIsRunning = false
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }

    fun currentDisplaySeconds(): Int {
        if (!lastIsRunning) return lastDisplaySeconds
        val elapsedSinceShow = ((SystemClock.elapsedRealtime() - lastShownAtRealtime) / 1000L)
            .coerceAtLeast(0L)
            .toInt()
        return if (lastMode == "unlimited") {
            lastDisplaySeconds + elapsedSinceShow
        } else {
            (lastDisplaySeconds - elapsedSinceShow).coerceAtLeast(0)
        }
    }

    private fun actionIntent(
        context: Context,
        action: String,
        plannedSeconds: Int,
        remainingSeconds: Int,
        mode: String
    ): PendingIntent {
        val requestCode = when (action) {
            ACTION_PAUSE -> 1
            ACTION_RESUME -> 2
            else -> 3
        }
        val intent = Intent(context, FocusTimerActionReceiver::class.java).apply {
            this.action = action
            putExtra(EXTRA_PLANNED_SECONDS, plannedSeconds)
            putExtra(EXTRA_REMAINING_SECONDS, remainingSeconds)
            putExtra(EXTRA_MODE, mode)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "\u4e13\u6ce8\u8ba1\u65f6",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "\u5728\u901a\u77e5\u680f\u548c\u9501\u5c4f\u663e\u793a\u4e13\u6ce8\u8ba1\u65f6\u63a7\u5236"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        manager.createNotificationChannel(channel)
    }
}
