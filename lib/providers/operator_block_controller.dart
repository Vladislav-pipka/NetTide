import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/operator_guard.dart';
import 'operator_guard_provider.dart';

final operatorBlockControllerProvider = Provider((ref) {
  final guard = ref.watch(operatorGuardProvider);
  final controller = OperatorBlockController(guard);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class OperatorBlockController {
  final OperatorGuard _guard;
  StreamSubscription? _guardSubscription;

  OperatorBlockController(this._guard) {
    // Listen to the stream from the guard.
    // The stream now emits TRUE for BLOCKED, and FALSE for SAFE.
    _guardSubscription = _guard.isBlockedStream.listen((isBlocked) {
      _updateNotification(isBlocked: isBlocked);
    });
  }

  void _updateNotification({required bool isBlocked}) {
    if (isBlocked) {
      // If the operator is in the blocklist, show a warning notification.
      NotificationService.showNotification(
        'Unwanted Network Detected',
        'Connected to a blocked operator. Open NetTide to manage your connection.',
      );
    } else {
      // If the network is safe, cancel any previous notifications to avoid confusion.
      NotificationService.cancelNotification();
    }
  }

  void dispose() {
    _guardSubscription?.cancel();
  }
}