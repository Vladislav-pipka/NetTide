import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';

// const Map<String, TranslateLanguage> languageMap = {
//   'en': TranslateLanguage.english,
//   'ru': TranslateLanguage.russian,
//   'es': TranslateLanguage.spanish,
//   'fr': TranslateLanguage.french,
//   'de': TranslateLanguage.german,
//   'it': TranslateLanguage.italian,
//   'pt': TranslateLanguage.portuguese,
//   'zh': TranslateLanguage.chinese,
//   'ja': TranslateLanguage.japanese,
//   'ko': TranslateLanguage.korean,
//   'ar': TranslateLanguage.arabic,
//   'hi': TranslateLanguage.hindi,
// };

class LocaleState {
  final Locale locale;
  final bool isLoading;
  final String? error;

  LocaleState({required this.locale, this.isLoading = false, this.error});
}

final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(LocaleState(locale: const Locale('en'))) {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    state = LocaleState(locale: Locale(languageCode));
  }

  void setLocale(Locale locale) async {
    if (state.locale != locale) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
      state = LocaleState(locale: locale);
    }
  }

  Future<void> downloadModel(Locale locale) async {
    // state = LocaleState(locale: state.locale, isLoading: true);

    // try {
    //   final targetLanguage = languageMap[locale.languageCode] ?? TranslateLanguage.english;
    //   final modelManager = OnDeviceTranslatorModelManager();

    //   if (!await modelManager.isModelDownloaded(targetLanguage.name)) {
    //     await modelManager.downloadModel(targetLanguage.name);
    //   }
    //   setLocale(locale);
    // } catch (e) {
    //   state = LocaleState(locale: state.locale, error: e.toString());
    // }
  }
}
