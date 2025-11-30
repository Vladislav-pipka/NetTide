import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../translations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'Русский', 'code': 'ru'},
      {'name': 'Español', 'code': 'es'},
      {'name': 'Français', 'code': 'fr'},
      {'name': 'Deutsch', 'code': 'de'},
      {'name': 'Português', 'code': 'pt'},
      {'name': '中文', 'code': 'zh'},
      {'name': 'हिन्दी', 'code': 'hi'},
      {'name': 'Bahasa Indonesia', 'code': 'id'},
      {'name': 'Filipino', 'code': 'fil'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('languageSelectionTitle')),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = localeState.locale.languageCode == language['code'];

              return ListTile(
                title: Text(language['name']!),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(Locale(language['code']!));
                },
              );
            },
          ),
          if (localeState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (localeState.error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.translate('errorDownloadingLanguage')),
                  const SizedBox(height: 10),
                  Text(localeState.error!),
                ],
              ),
            ),
        ],
      ),
    );
  }
}