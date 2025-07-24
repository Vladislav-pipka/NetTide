import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotification = ref.watch(notificationSettingsProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Show Persistent Notification'),
            subtitle: const Text('Keeps you informed about the protection status.'),
            value: showNotification,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).setShowNotification(value);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
            trailing: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onTap: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Warning: Disabling the persistent notification may cause the Android system to stop the background service to save memory. This can leave you unprotected without you knowing. It is highly recommended to keep this enabled.',
              style: TextStyle(color: Colors.red.shade700, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}