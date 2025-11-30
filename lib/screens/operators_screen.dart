import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country.dart';
import '../models/operator.dart';
import '../providers/settings_provider.dart';
import '../translations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${l10n.translate('editPriceFor')} ${operator.name}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: l10n.translate('enterNewPricePerMB'),
              prefixText: '\$',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                final newPrice = double.tryParse(controller.text);
                if (newPrice != null) {
                  ref.read(settingsProvider.notifier).setOperatorPrice(operator.uniqueId, newPrice);
                }
                Navigator.of(context).pop();
              },
              child: Text(l10n.translate('save')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final operatorUniqueIds = country.operators.map((op) => op.uniqueId).toList();
    final l10n = AppLocalizations.of(context)!;

    final isCountryEnabled = operatorUniqueIds.any((id) => settingsState.operatorSettings[id]?.isEnabled ?? true);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate(country.name.trim())),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: country.operators.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              color: isCountryEnabled ? Colors.white : Colors.grey[400],
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.all(12.0),
                title: Text(
                  isCountryEnabled ? l10n.translate('disableAll') : l10n.translate('enableAll'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                value: isCountryEnabled,
                onChanged: (bool value) {
                  ref.read(settingsProvider.notifier).setCountryEnabled(operatorUniqueIds, value);
                },
                activeColor: Colors.green,
              ),
            );
          }

          final operator = country.operators[index - 1];
          final operatorSetting = settingsState.operatorSettings[operator.uniqueId];
          final isEnabled = operatorSetting?.isEnabled ?? true;
          final price = operatorSetting?.customPrice ?? operator.pricePerMb;

          return Card(
            color: isEnabled ? Colors.white : Colors.grey[400],
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.all(12.0),
              title: Text(operator.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditPriceDialog(context, ref, operator),
                      child: Text(
                        '${l10n.translate('price')}: \$${price.toStringAsFixed(2)}/MB (${l10n.translate('tapToEdit')})',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchURL(context, operator.url),
                      child: Text(
                        operator.url,
                        style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              value: isEnabled,
              onChanged: (bool? value) {
                ref.read(settingsProvider.notifier).setOperatorEnabled(operator.uniqueId, value ?? true);
              },
              activeColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}