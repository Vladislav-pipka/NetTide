
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/region.dart';

class DataService {
  Future<List<Region>> loadRegions() async {
    final String response = await rootBundle.loadString('lib/data/operators_data.json');
    final data = await json.decode(response) as List;
    return data.map((json) => Region.fromJson(json)).toList();
  }
}
