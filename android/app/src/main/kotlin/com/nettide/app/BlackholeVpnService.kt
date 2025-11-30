package com.nettide.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat

class BlackholeVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    companion object {
        const val ACTION_CONNECT = "com.nettide.app.ACTION_CONNECT"
        const val ACTION_DISCONNECT = "com.nettide.app.ACTION_DISCONNECT"
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_CONNECT) {
            startVpn()
        } else if (intent?.action == ACTION_DISCONNECT) {
            stopVpn()
        }
        return START_STICKY
    }

    private fun startVpn() {
        // Create a notification for the foreground service
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "vpn_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "VPN Status", NotificationManager.IMPORTANCE_DEFAULT)
            notificationManager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("NetTide Guard")
            .setContentText("Internet access is blocked for the current operator.")
            .setSmallIcon(R.mipmap.ic_launcher) // Make sure you have this icon
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)

        // Start the VPN
        vpnInterface = Builder()
            .addAddress("10.1.2.3", 32)
            .addRoute("0.0.0.0", 0) // Intercept all traffic
            .setSession(application.packageName)
            .establish()
    }

    private fun stopVpn() {
        vpnInterface?.close()
        vpnInterface = null
        stopForeground(true)
        stopSelf()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }
}
