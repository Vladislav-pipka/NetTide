import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data class for a single operator's settings
class OperatorSetting {
  final bool isEnabled;
  final double? customPrice;

  OperatorSetting({this.isEnabled = true, this.customPrice});
}

// State class holding all app settings
class SettingsState {
  final Map<String, OperatorSetting> operatorSettings;

  SettingsState({required this.operatorSettings});

  SettingsState copyWith({
    Map<String, OperatorSetting>? operatorSettings,
  }) {
    return SettingsState(
      operatorSettings: operatorSettings ?? this.operatorSettings,
    );
  }
}

// Notifier to manage and persist settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(operatorSettings: {})) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, OperatorSetting> settings = {};
    for (String key in keys) {
      if (key.startsWith('op_enabled_')) {
        final uniqueId = key.substring(11);
        final isEnabled = prefs.getBool(key) ?? true;
        final customPrice = prefs.getDouble('op_price_$uniqueId');
        settings[uniqueId] = OperatorSetting(isEnabled: isEnabled, customPrice: customPrice);
      }
    }
    state = state.copyWith(operatorSettings: settings);
  }

  void setOperatorEnabled(String uniqueId, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('op_enabled_$uniqueId', isEnabled);
    final newSettings = {
      ...state.operatorSettings,
      uniqueId: OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state.operatorSettings[uniqueId]?.customPrice,
      ),
    };
    state = state.copyWith(operatorSettings: newSettings);
  }

  void setOperatorPrice(String uniqueId, double price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('op_price_$uniqueId', price);
    final newSettings = {
      ...state.operatorSettings,
      uniqueId: OperatorSetting(
        isEnabled: state.operatorSettings[uniqueId]?.isEnabled ?? true,
        customPrice: price,
      ),
    };
    state = state.copyWith(operatorSettings: newSettings);
  }

  void setCountryEnabled(List<String> operatorUniqueIds, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, OperatorSetting> updatedSettings = {...state.operatorSettings};
    for (var id in operatorUniqueIds) {
      await prefs.setBool('op_enabled_$id', isEnabled);
      updatedSettings[id] = OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state.operatorSettings[id]?.customPrice,
      );
    }
    state = state.copyWith(operatorSettings: updatedSettings);
  }

  void setAllOperatorsEnabled(List<String> allOperatorUniqueIds, bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, OperatorSetting> updatedSettings = {...state.operatorSettings};
    for (var id in allOperatorUniqueIds) {
      await prefs.setBool('op_enabled_$id', isEnabled);
      updatedSettings[id] = OperatorSetting(
        isEnabled: isEnabled,
        customPrice: state.operatorSettings[id]?.customPrice,
      );
    }
    state = state.copyWith(operatorSettings: updatedSettings);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});