
package com.example.nettide

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.nettide/network"
    companion object {
        const val NOTIFICATION_CHANNEL_ID = "network_status"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannel()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "setBlockedOperators") {
                val blockedOperators = call.argument<List<String>>("blockedOperators")
                val showNotification = call.argument<Boolean>("showNotification") ?: true
                val serviceIntent = Intent(this, NetworkBouncerService::class.java).apply {
                    putStringArrayListExtra("blockedOperators", ArrayList(blockedOperators))
                    putExtra("showNotification", showNotification)
                }
                startService(serviceIntent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Network Status"
            val descriptionText = "Shows the current network status and protection state"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
