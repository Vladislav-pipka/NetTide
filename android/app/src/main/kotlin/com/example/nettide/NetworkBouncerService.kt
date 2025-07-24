
package com.example.nettide

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.VpnService
import android.os.Build
import android.os.IBinder
import android.telephony.TelephonyManager
import androidx.core.app.NotificationCompat

class NetworkBouncerService : Service() {

    private lateinit var connectivityManager: ConnectivityManager
    private lateinit var telephonyManager: TelephonyManager
    private var blockedOperators = listOf<String>()
    private var isVpnActive = false

    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            super.onAvailable(network)
            checkNetworkStatus()
        }

        override fun onLost(network: Network) {
            super.onLost(network)
            checkNetworkStatus()
        }
    }

    override fun onCreate() {
        super.onCreate()
        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        connectivityManager.registerDefaultNetworkCallback(networkCallback)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        blockedOperators = intent?.getStringArrayListExtra("blockedOperators") ?: blockedOperators
        
        val showNotification = intent?.getBooleanExtra("showNotification", true) ?: true

        if (showNotification) {
            val notification = createNotification("NetTide is running", "Monitoring network connections...")
            startForeground(1, notification)
        } else {
            stopForeground(true)
        }

        checkNetworkStatus()

        return START_STICKY
    }

    private fun checkNetworkStatus() {
        val activeNetwork = connectivityManager.activeNetwork
        val capabilities = connectivityManager.getNetworkCapabilities(activeNetwork)

        if (capabilities == null) {
            updateNotification("No Connection", "Waiting for network...")
            stopVpn()
            return
        }

        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
            updateNotification("Connected to Wi-Fi", "Protection is idle.")
            stopVpn()
        } else if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
            val operatorMccMnc = telephonyManager.networkOperator
            val operatorName = telephonyManager.networkOperatorName

            if (blockedOperators.contains(operatorName)) {
                updateNotification("DATA BLOCKED", "Connected to disabled operator: $operatorName")
                startVpn()
            } else {
                updateNotification("Protected", "Connected to $operatorName")
                stopVpn()
            }
        }
    }

    private fun startVpn() {
        if (!isVpnActive) {
            val vpnIntent = VpnService.prepare(this)
            if (vpnIntent != null) {
                // This should be handled in the UI by requesting permission.
                // For now, we assume permission is granted.
            } else {
                startService(Intent(this, BlockAllVpnService::class.java))
                isVpnActive = true
            }
        }
    }

    private fun stopVpn() {
        if (isVpnActive) {
            stopService(Intent(this, BlockAllVpnService::class.java))
            isVpnActive = false
        }
    }

    private fun createNotification(title: String, text: String): Notification {
        val pendingIntent: PendingIntent =
            Intent(this, MainActivity::class.java).let { notificationIntent ->
                PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)
            }

        return NotificationCompat.Builder(this, MainActivity.NOTIFICATION_CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(R.drawable.ic_stat_name) // You need to create this icon
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(title: String, text: String) {
        val notification = createNotification(title, text)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.notify(1, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        connectivityManager.unregisterNetworkCallback(networkCallback)
        stopVpn()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}

class BlockAllVpnService : VpnService() {
    private var vpnInterface: android.os.ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val builder = Builder()
        vpnInterface = builder.setSession("NetTide VPN")
            .addAddress("10.0.0.1", 24)
            .addRoute("0.0.0.0", 0) // Block all IPv4 traffic
            .addRoute("::", 0)    // Block all IPv6 traffic
            .establish()
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        vpnInterface?.close()
    }
}
