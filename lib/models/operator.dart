class Operator {
  final String name;
  final double pricePerMb;
  final String url;
  bool isEnabled;

  Operator({
    required this.name,
    required this.pricePerMb,
    required this.url,
    this.isEnabled = true,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      name: json['name'] as String? ?? 'Unknown Operator',
      pricePerMb: (json['price_per_mb'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String? ?? '',
    );
  }
}