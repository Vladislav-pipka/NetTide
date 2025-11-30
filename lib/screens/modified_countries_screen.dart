import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../translations.dart';
import '../models/country.dart';
import '../providers/data_provider.dart';
import '../providers/settings_provider.dart';
import 'operators_screen.dart';

class ModifiedCountriesScreen extends ConsumerWidget {
  const ModifiedCountriesScreen({Key? key}) : super(key: key);

  String getCountryFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCountries = ref.watch(allCountriesProvider);
    final settingsState = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    final modifiedCountries = allCountries.where((country) {
      return country.operators.any((operator) {
        final operatorSettings = settingsState.operatorSettings[operator.uniqueId];
        return operatorSettings != null && (!operatorSettings.isEnabled || operatorSettings.customPrice != null);
      });
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('modifiedCountries')),
      ),
      body: modifiedCountries.isEmpty
          ? Center(
              child: Text(l10n.translate('noCountriesModified')),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: modifiedCountries.length,
              itemBuilder: (context, index) {
                final country = modifiedCountries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Text(getCountryFlag(country.countryCode), style: const TextStyle(fontSize: 28)),
                    title: Text(country.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OperatorsScreen(country: country),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}