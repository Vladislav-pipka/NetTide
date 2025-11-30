package com.nettide.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val vpnChannel = "com.nettide.app/vpn"
    private val vpnRequestCode = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    startVpnService()
                    result.success(null)
                }
                "stopVpn" -> {
                    stopVpnService()
                    result.success(null)
                }
                "prepareVpn" -> {
                    prepareVpnService(result)
                }
                "getNetworkOperator" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        getNetworkOperator(result)
                    } else {
                        result.error("UNSUPPORTED", "This feature requires Android Q or higher.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnService() {
        val intent = Intent(this, BlackholeVpnService::class.java).setAction(BlackholeVpnService.ACTION_CONNECT)
        startService(intent)
    }

    private fun stopVpnService() {
        val intent = Intent(this, BlackholeVpnService::class.java).setAction(BlackholeVpnService.ACTION_DISCONNECT)
        startService(intent)
    }

    private fun prepareVpnService(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent != null) {
            startActivityForResult(intent, vpnRequestCode)
            // We can't return the result immediately, so we'll handle it in onActivityResult
        } else {
            // Already prepared
            onActivityResult(vpnRequestCode, Activity.RESULT_OK, null)
            result.success(true)
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun getNetworkOperator(result: MethodChannel.Result) {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val operator = telephonyManager.networkOperator
        if (operator != null && operator.isNotEmpty()) {
            result.success(operator)
        } else {
            result.error("UNAVAILABLE", "Network operator not available.", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == vpnRequestCode && resultCode == Activity.RESULT_OK) {
            // VPN permission granted
            // You might want to notify Dart side here if needed
        }
    }
}