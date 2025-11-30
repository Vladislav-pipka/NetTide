import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../translations.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotification = ref.watch(notificationSettingsProvider);
    final themeMode = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(l10n.translate('showPersistentNotification')),
            value: showNotification,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setShowNotification(value);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(themeMode == ThemeMode.dark ? l10n.translate('switchToLightMode') : l10n.translate('switchToDarkMode')),
            trailing: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.translate('changeLanguage')),
            trailing: const Icon(Icons.language),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
