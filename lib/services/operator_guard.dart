import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/settings_provider.dart';
import 'vpn_service.dart'; // Import the new VpnService

class OperatorGuard {
  StreamSubscription? _connectivitySubscription;
  SettingsState? _settings;

  final _isBlockedController = StreamController<bool>.broadcast();
  Stream<bool> get isBlockedStream => _isBlockedController.stream;

  Future<void> initialize(SettingsState settings) async {
    _settings = settings;
    if (Platform.isAndroid) {
      await VpnService.prepareVpn(); // Prepare VPN on initialization
    }
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    developer.log('OperatorGuard initialized');
    _checkCurrentNetwork(); // Initial check
  }

  void updateSettings(SettingsState settings) {
    developer.log('OperatorGuard settings updated');
    _settings = settings;
    _checkCurrentNetwork();
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> result) async {
    developer.log('Connectivity changed: $result');
    await _checkCurrentNetwork();
  }

  Future<void> _checkCurrentNetwork() async {
    developer.log('Checking current network...');
    if (_settings == null) {
      developer.log('Settings are null, cannot check network.');
      _reportSafe();
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      developer.log('Connected to Wi-Fi, stopping VPN.');
      _reportSafe();
      return;
    }

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      developer.log('Connected to mobile network, checking carrier...');
      String? operatorId;

      try {
        if (Platform.isAndroid) {
          // Use the new VpnService to get the operator
          final operator = await VpnService.getNetworkOperator();
          if (operator != null && operator.length >= 5) {
            // Assuming operator is MCC+MNC
            operatorId = '${operator.substring(0, 3)}-${operator.substring(3)}';
          }
        }
        // TODO: Add iOS implementation if needed
      } catch (e) {
        developer.log('Error getting carrier info: $e');
        _reportSafe(); // Report safe on error
        return;
      }

      developer.log('Operator ID: $operatorId');

      if (operatorId != null) {
        final operatorSettings = _settings!.operatorSettings[operatorId];
        developer.log('Checking operator: $operatorId, Settings: $operatorSettings');

        if (operatorSettings != null && !operatorSettings.isEnabled) {
          developer.log('Operator is in the blocklist. Starting VPN.');
          _reportBlocked();
        } else {
          developer.log('Operator is allowed. Stopping VPN.');
          _reportSafe();
        }
      } else {
        developer.log('Operator ID is null. Stopping VPN.');
        _reportSafe();
      }
    } else {
      developer.log('Not on Wi-Fi or mobile. Stopping VPN.');
      _reportSafe();
    }
  }

  void _reportBlocked() {
    if (Platform.isAndroid) {
      VpnService.startVpn();
    }
    _isBlockedController.add(true);
  }

  void _reportSafe() {
    if (Platform.isAndroid) {
      VpnService.stopVpn();
    }
    _isBlockedController.add(false);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _isBlockedController.close();
    developer.log('OperatorGuard disposed');
  }
}
