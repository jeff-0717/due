package com.example.due

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat

class FocusTimerActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = NotificationManagerCompat.from(context)
        when (intent.action) {
            FocusTimerNotifications.ACTION_FINISH -> {
                MainActivity.dispatchFocusAction("finish")
                notificationManager.cancel(FocusTimerNotifications.NOTIFICATION_ID)
            }
            FocusTimerNotifications.ACTION_PAUSE,
            FocusTimerNotifications.ACTION_RESUME -> {
                val isRunning = intent.action == FocusTimerNotifications.ACTION_RESUME
                val action = if (isRunning) "resume" else "pause"
                val handledByFlutter = MainActivity.dispatchFocusAction(action)
                if (!handledByFlutter) {
                    FocusTimerNotifications.show(
                        context = context,
                        plannedSeconds = intent.getIntExtra(
                            FocusTimerNotifications.EXTRA_PLANNED_SECONDS,
                            2700
                        ),
                        remainingSeconds = FocusTimerNotifications.currentDisplaySeconds(),
                        isRunning = isRunning,
                        mode = intent.getStringExtra(FocusTimerNotifications.EXTRA_MODE)
                            ?: "fixed45"
                    )
                }
            }
        }
    }
}
