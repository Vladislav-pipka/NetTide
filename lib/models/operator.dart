class Operator {
  final String name;
  final double pricePerMb;
  final String url;
  final String uniqueId; // Added for unique identification
  bool isEnabled;

  Operator({
    required this.name,
    required this.pricePerMb,
    required this.url,
    required this.uniqueId,
    this.isEnabled = true,
  });

  factory Operator.fromJson(Map<String, dynamic> json, String countryCode) {
    final mcc = json['mcc'] as String?;
    final mnc = json['mnc'] as String?;
    String id;

    if (mcc != null && mnc != null && mcc.isNotEmpty && mnc.isNotEmpty) {
      id = '$mcc-$mnc';
    } else {
      id = '$countryCode-${json['name']}';
    }

    return Operator(
      name: json['name'] as String? ?? 'Unknown Operator',
      pricePerMb: (json['price_per_mb'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String? ?? '',
      uniqueId: id,
    );
  }
}