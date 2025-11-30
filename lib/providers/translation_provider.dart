import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../services/translation_service.dart';
import 'locale_provider.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

final translationProvider = FutureProvider.autoDispose.family<String, String>((ref, text) async {
  // final translationService = ref.watch(translationServiceProvider);
  // final localeState = ref.watch(localeProvider);

  // final sourceLanguage = TranslateLanguage.english;
  // final targetLanguage = languageMap[localeState.locale.languageCode] ?? TranslateLanguage.english;

  // if (sourceLanguage == targetLanguage) {
  //   return text;
  // }

  // final translator = translationService.getTranslator(sourceLanguage, targetLanguage);
  // final translatedText = await translator.translateText(text);
  // translator.close();

  return text;
});
