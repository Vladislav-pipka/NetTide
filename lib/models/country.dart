
import 'operator.dart';

class Country {
  final String name;
  final String countryCode;
  final List<Operator> operators;

  Country({required this.name, required this.countryCode, required this.operators});

  factory Country.fromJson(Map<String, dynamic> json) {
    var operatorList = json['operators'] as List? ?? [];
    List<Operator> operators = operatorList.map((i) => Operator.fromJson(i, json['country_code'] as String? ?? '')).toList();

    return Country(
      name: json['name'] as String? ?? 'Unknown Country',
      countryCode: json['country_code'] as String? ?? '',
      operators: operators,
    );
  }
}
