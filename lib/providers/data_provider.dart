import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../models/region.dart';
import '../services/data_service.dart';

final regionsProvider = FutureProvider<List<Region>>((ref) {
  final dataService = DataService();
  return dataService.loadRegions();
});

final allCountriesProvider = Provider<List<Country>>((ref) {
  return ref.watch(regionsProvider).when(
        data: (regions) => regions.expand((region) => region.countries).toList(),
        loading: () => [],
        error: (err, stack) => [],
      );
});