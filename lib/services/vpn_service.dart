import 'package:flutter/services.dart';

class VpnService {
  static const _platform = MethodChannel('com.nettide.app/vpn');

  static Future<void> startVpn() async {
    try {
      await _platform.invokeMethod('startVpn');
    } on PlatformException catch (e) {
      print("Failed to start VPN: '${e.message}'.");
    }
  }

  static Future<void> stopVpn() async {
    try {
      await _platform.invokeMethod('stopVpn');
    } on PlatformException catch (e) {
      print("Failed to stop VPN: '${e.message}'.");
    }
  }

  static Future<bool> prepareVpn() async {
    try {
      return await _platform.invokeMethod('prepareVpn');
    } on PlatformException catch (e) {
      print("Failed to prepare VPN: '${e.message}'.");
      return false;
    }
  }

  static Future<String?> getNetworkOperator() async {
    try {
      final String? operator = await _platform.invokeMethod('getNetworkOperator');
      return operator;
    } on PlatformException catch (e) {
      print("Failed to get network operator: '${e.message}'.");
      return null;
    }
  }
}
