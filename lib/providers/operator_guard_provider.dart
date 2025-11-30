import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../services/operator_guard.dart';
import 'settings_provider.dart';

final operatorGuardProvider = Provider<OperatorGuard>((ref) {
  print('>>> operatorGuardProvider factory is running!'); // Используем print для надежности

  final operatorGuard = OperatorGuard();

  try {
    final initialSettings = ref.read(settingsProvider);
    // Запускаем асинхронную инициализацию в microtask, чтобы не блокировать фабрику
    Future.microtask(() async {
      try {
        await operatorGuard.initialize(initialSettings);
        print('>>> OperatorGuard.initialize completed successfully');
      } catch (e, st) {
        print('>>> CRITICAL: OperatorGuard.initialize ASYNC EXCEPTION: $e\n$st');
      }
    });
  } catch (e, st) {
    print('>>> CRITICAL: OperatorGuard factory SYNC EXCEPTION: $e');
  }

  ref.onDispose(() {
    operatorGuard.dispose();
  });

  // Listen for changes in settings and just update the existing guard instance.
  ref.listen(settingsProvider, (previous, next) {
    operatorGuard.updateSettings(next);
  });

  return operatorGuard;
});

final operatorBlockedProvider = StreamProvider<bool>((ref) {
  final operatorGuard = ref.watch(operatorGuardProvider);
  return operatorGuard.isBlockedStream;
});