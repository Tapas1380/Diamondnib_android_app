package com.diamondnib.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        println("FCM: New token generated: $token")
        // Token will be automatically handled by Flutter Firebase Messaging plugin
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        // Handle data payload
        if (remoteMessage.data.isNotEmpty()) {
            println("FCM: Data payload: ${remoteMessage.data}")
        }
        
        // Handle notification payload
        remoteMessage.notification?.let { notification ->
            println("FCM: Notification Title: ${notification.title}")
            println("FCM: Notification Body: ${notification.body}")
            
            // Create and show notification for background messages
            sendNotification(notification.title, notification.body, remoteMessage.data)
        }
    }

    private fun sendNotification(title: String?, body: String?, data: Map<String, String>) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "High Importance Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "This channel is used for important notifications"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val notificationBuilder = NotificationCompat.Builder(this, "high_importance_channel")
            .setContentTitle(title ?: "New Notification")
            .setContentText(body ?: "You have a new message")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Use your app icon
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        notificationManager.notify(0, notificationBuilder.build())
    }
}