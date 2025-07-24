import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../providers/data_provider.dart';
import '../providers/settings_provider.dart';
import 'operators_screen.dart';



import 'settings_screen.dart';
import 'faq_screen.dart';

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
    final filteredCountries = allCountries
        .where((country) => country.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NetTide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'FAQ',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FaqScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.public_off),
              label: const Text('Disable All Countries'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Disable All Countries?'),
                    content: const Text(
                        'This will disable all mobile operators in the app. You will not be able to use mobile data from any listed operator until you re-enable them. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final allOperatorNames = allCountries
                              .expand((country) => country.operators)
                              .map((op) => op.name)
                              .toList();
                          ref.read(settingsProvider.notifier).setAllOperatorsEnabled(allOperatorNames, false);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All countries have been disabled.')),
                          );
                        },
                        child: const Text('Disable All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                hintText: 'Search for a country...',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredCountries.length,
        itemBuilder: (context, index) {
          final country = filteredCountries[index];
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => PriceThresholdDialog(ref: ref),
        ),
        icon: const Icon(Icons.money_off),
        label: const Text('Disable Expensive'),
      ),
    );
  }
}

class PriceThresholdDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const PriceThresholdDialog({Key? key, required this.ref}) : super(key: key);

  @override
  _PriceThresholdDialogState createState() => _PriceThresholdDialogState();
}

class _PriceThresholdDialogState extends ConsumerState<PriceThresholdDialog> {
  double _currentSliderValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disable Expensive Networks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Disable networks more expensive than: \$${_currentSliderValue.toStringAsFixed(2)}'),
          Slider(
            value: _currentSliderValue,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            label: _currentSliderValue.toStringAsFixed(2),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final regionsAsyncValue = widget.ref.read(regionsProvider);
            if (regionsAsyncValue.hasValue) {
              final allOperators = regionsAsyncValue.value!
                  .expand((region) => region.countries)
                  .expand((country) => country.operators);

              for (final operator in allOperators) {
                if (operator.pricePerMb > _currentSliderValue) {
                  widget.ref.read(settingsProvider.notifier).setOperatorEnabled(operator.name, false);
                }
              }
            }
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expensive networks have been disabled.')),
            );
          },
          child: const Text('Disable'),
        ),
      ],
    );
  }
}