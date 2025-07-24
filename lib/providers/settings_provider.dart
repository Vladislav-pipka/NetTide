import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperatorSetting {
  final bool isEnabled;
  final double? customPrice;

  OperatorSetting({this.isEnabled = true, this.customPrice});
}

class SettingsNotifier extends StateNotifier<Map<String, OperatorSetting>> {
  final MethodChannel _channel = const MethodChannel('com.example.nettide/network');

  SettingsNotifier() : super({}) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, OperatorSetting> settings = {};
    for (String key in keys) {
      if (key.startsWith('op_enabled_')) {
        final operatorName = key.substring(11);
        final isEnabled = prefs.getBool(key) ?? true;
        final customPrice = prefs.getDouble('op_price_$operatorName');
        settings[operatorName] = OperatorSetting(isEnabled: isEnabled, customPrice: customPrice);
      }
    }
    state = settings;
    _updateBlockedOperators();
  }

  void setOperatorEnabled(String operatorName, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('op_enabled_$operatorName', isEnabled);
    state = {
      ...state,
      operatorName: OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state[operatorName]?.customPrice,
      ),
    };
    _updateBlockedOperators();
  }

  void setOperatorPrice(String operatorName, double price) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('op_price_$operatorName', price);
    state = {
      ...state,
      operatorName: OperatorSetting(
        isEnabled: state[operatorName]?.isEnabled ?? true,
        customPrice: price,
      ),
    };
  }

  void setCountryEnabled(List<String> operatorNames, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, OperatorSetting> updatedSettings = {...state};
    for (var name in operatorNames) {
      prefs.setBool('op_enabled_$name', isEnabled);
      updatedSettings[name] = OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state[name]?.customPrice,
      );
    }
    state = updatedSettings;
    _updateBlockedOperators();
  }

  void setAllOperatorsEnabled(List<String> allOperatorNames, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, OperatorSetting> updatedSettings = {...state};
    for (var name in allOperatorNames) {
      prefs.setBool('op_enabled_$name', isEnabled);
      updatedSettings[name] = OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state[name]?.customPrice,
      );
    }
    state = updatedSettings;
    _updateBlockedOperators();
  }

  void _updateBlockedOperators() {
    final blockedOperators = state.entries
        .where((entry) => !entry.value.isEnabled)
        .map((entry) => entry.key)
        .toList();
    _channel.invokeMethod('setBlockedOperators', {'blockedOperators': blockedOperators});
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, OperatorSetting>>((ref) {
  return SettingsNotifier();
});