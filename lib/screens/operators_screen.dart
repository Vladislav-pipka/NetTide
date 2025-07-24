import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../models/operator.dart';
import '../providers/settings_provider.dart';

class OperatorsScreen extends ConsumerWidget {
  final Country country;

  const OperatorsScreen({Key? key, required this.country}) : super(key: key);

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _showEditPriceDialog(BuildContext context, WidgetRef ref, Operator operator) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Price for ${operator.name}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter new price per MB',
              prefixText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(controller.text);
                if (newPrice != null) {
                  ref.read(settingsProvider.notifier).setOperatorPrice(operator.name, newPrice);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final operatorNames = country.operators.map((op) => op.name).toList();

    final isCountryEnabled = operatorNames.any((name) => settings[name]?.isEnabled ?? true);

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: country.operators.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              color: isCountryEnabled ? Colors.white : Colors.grey[300],
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.all(12.0),
                title: Text(
                  isCountryEnabled ? 'All Enabled' : 'All Disabled',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                value: isCountryEnabled,
                onChanged: (bool value) {
                  ref.read(settingsProvider.notifier).setCountryEnabled(operatorNames, value);
                },
                activeColor: Colors.green,
              ),
            );
          }

          final operator = country.operators[index - 1];
          final operatorSetting = settings[operator.name];
          final isEnabled = operatorSetting?.isEnabled ?? true;
          final price = operatorSetting?.customPrice ?? operator.pricePerMb;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.all(12.0),
              title: Text(operator.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditPriceDialog(context, ref, operator),
                      child: Text(
                        'Price: \$${price.toStringAsFixed(2)}/MB (tap to edit)',
                        style: TextStyle(color: operatorSetting?.customPrice != null ? Colors.purple : Colors.black),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchURL(context, operator.url),
                      child: Text(
                        operator.url,
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              value: isEnabled,
              onChanged: (bool? value) {
                ref.read(settingsProvider.notifier).setOperatorEnabled(operator.name, value ?? true);
              },
              activeColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}