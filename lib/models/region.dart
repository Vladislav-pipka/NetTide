import 'country.dart';

class Region {
  final String name;
  final List<Country> countries;

  Region({required this.name, required this.countries});

  factory Region.fromJson(Map<String, dynamic> json) {
    var countryList = json['countries'] as List? ?? [];
    List<Country> countries = countryList.map((i) => Country.fromJson(i)).toList();

    return Region(
      name: json['region'] as String? ?? 'Unknown Region',
      countries: countries,
    );
  }
}