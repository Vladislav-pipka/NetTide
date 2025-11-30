import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../translations.dart';
import '../models/country.dart';
import '../providers/data_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/operator_guard_provider.dart';
import 'operators_screen.dart';

import 'settings_screen.dart';
import 'faq_screen.dart';
import 'modified_countries_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  String getCountryFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
  }

  @override
  Widget build(BuildContext context) {
    final allCountries = ref.watch(allCountriesProvider);
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(settingsProvider);
    final operatorGuard = ref.watch(operatorGuardProvider);

    final filteredCountries = allCountries.where((country) {
      final translatedName = l10n.translate(country.name.trim()).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return translatedName.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('nettide')),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isBlocked = ref.watch(operatorBlockedProvider).asData?.value ?? false;
              return Tooltip(
                message: isBlocked ? l10n.translate('networkBlocked') : l10n.translate('networkProtected'),
                child: Icon(
                  isBlocked ? Icons.shield : Icons.shield_outlined,
                  color: isBlocked ? Colors.red : Colors.white,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: l10n.translate('listOfCountries'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ModifiedCountriesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.translate('settings'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.translate('faq'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FaqScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.money_off),
            tooltip: l10n.translate('enableDisableExpensiveNetworks'),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const PriceThresholdDialog(),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final settingsState = ref.watch(settingsProvider);
              final allOperatorUniqueIds = ref.watch(allCountriesProvider)
                  .expand((country) => country.operators)
                  .map((op) => op.uniqueId)
                  .toList();

              bool areAllEnabled = allOperatorUniqueIds.every((id) => settingsState.operatorSettings[id]?.isEnabled ?? true);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(areAllEnabled ? Icons.public : Icons.public_off, color: Colors.white),
                  tooltip: areAllEnabled ? l10n.translate('disableAll') : l10n.translate('enableAll'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.translate(areAllEnabled ? 'disableAllOperators' : 'enableAllOperators')),
                        content: Text(l10n.translate('areYouSure', args: {'action': l10n.translate(areAllEnabled ? 'disable' : 'enable')})),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.translate('cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(settingsProvider.notifier).setAllOperatorsEnabled(allOperatorUniqueIds, !areAllEnabled);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(areAllEnabled ? l10n.translate('allOperatorsDisabled') : l10n.translate('allOperatorsEnabled'))),
                              );
                            },
                            child: Text(areAllEnabled ? l10n.translate('disableAll') : l10n.translate('enableAll'), style: TextStyle(color: areAllEnabled ? Colors.red : Colors.green)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.translate('searchForACountry'),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // This space is intentionally left blank.
          // The status is now shown as an icon in the AppBar.
          const SizedBox.shrink(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                final settings = ref.watch(settingsProvider);
                final allOperatorsEnabled = country.operators.every((op) => settings.operatorSettings[op.uniqueId]?.isEnabled ?? true);

                return Card(
                  color: allOperatorsEnabled ? Colors.white : Colors.grey[400],
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Text(getCountryFlag(country.countryCode), style: const TextStyle(fontSize: 28)),
                    title: Text(l10n.translate(country.name.trim()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
          ),
        ],
      ),
    );
  }
}

class PriceThresholdDialog extends ConsumerStatefulWidget {
  const PriceThresholdDialog({Key? key}) : super(key: key);

  @override
  _PriceThresholdDialogState createState() => _PriceThresholdDialogState();
}

class _PriceThresholdDialogState extends ConsumerState<PriceThresholdDialog> {
  double _currentSliderValue = 1.0;
  bool _disable = true; // true to disable, false to enable

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.translate('enableDisableExpensiveNetworks')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.translate(_disable ? 'disableNetworksMoreThan' : 'enableNetworksMoreThan', args: {'price': '\$${_currentSliderValue.toStringAsFixed(2)}'})),
          Slider(
            value: _currentSliderValue,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            label: '\$${_currentSliderValue.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(_disable ? l10n.translate('disable') : l10n.translate('enable')),
            value: _disable,
            onChanged: (value) {
              setState(() {
                _disable = value;
              });
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            final regionsAsyncValue = ref.read(regionsProvider);
            if (regionsAsyncValue.hasValue) {
              final allOperators = regionsAsyncValue.value!
                  .expand((region) => region.countries)
                  .expand((country) => country.operators);

              for (final operator in allOperators) {
                if (operator.pricePerMb > _currentSliderValue) {
                  ref.read(settingsProvider.notifier).setOperatorEnabled(operator.uniqueId, !_disable);
                }
              }
            }
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_disable ? l10n.translate('expensiveNetworksDisabled') : l10n.translate('expensiveNetworksEnabled'))),
            );
          },
          child: Text(_disable ? l10n.translate('disable') : l10n.translate('enable')),
        ),
      ],
    );
  }
}
