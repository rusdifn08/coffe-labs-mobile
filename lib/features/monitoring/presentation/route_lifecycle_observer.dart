import 'dart:async';
import 'package:flutter/widgets.dart';
import '../data/telemetry_batch_outbox_service.dart';

/// Observer GoRouter & AppLifecycle untuk mengukur Active Screen Time secara presisi & hemat baterai.
class CoffeeLabsRouteAndLifecycleObserver extends NavigatorObserver
    with WidgetsBindingObserver {
  final TelemetryBatchOutboxService _outbox;

  final Stopwatch _activeWatch = Stopwatch();
  String _currentRoute = '/';
  bool _attachedLifecycle = false;

  CoffeeLabsRouteAndLifecycleObserver(this._outbox) {
    attachLifecycle();
  }

  void attachLifecycle() {
    if (_attachedLifecycle) return;
    _attachedLifecycle = true;
    WidgetsBinding.instance.addObserver(this);
    _activeWatch.start();
    _outbox.enqueueLifecycleEvent('SESSION_START', routeName: _currentRoute);
  }

  void detachLifecycle() {
    if (!_attachedLifecycle) return;
    _attachedLifecycle = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _commitCurrentDwellAndSwitch(String nextRoute) {
    final elapsedSec = _activeWatch.elapsed.inSeconds;
    _activeWatch.reset();
    if (elapsedSec > 0) {
      _outbox.enqueueScreenDwell(
        routeName: _currentRoute,
        elapsedSeconds: elapsedSec,
      );
    }
    _currentRoute = nextRoute;
    _outbox.updateActiveRoute(nextRoute);
    _activeWatch.start();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name ?? previousRoute?.settings.name ?? _currentRoute;
    _commitCurrentDwellAndSwitch(name.isNotEmpty ? name : '/');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name ?? _currentRoute;
    if (name.isNotEmpty) {
      _commitCurrentDwellAndSwitch(name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final backName = previousRoute?.settings.name ?? '/';
    _commitCurrentDwellAndSwitch(backName.isNotEmpty ? backName : '/');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _outbox.rotateSession();
        _outbox.enqueueLifecycleEvent('SESSION_START', routeName: _currentRoute);
        _activeWatch.reset();
        _activeWatch.start();
        unawaited(_outbox.sendHeartbeat());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        final elapsed = _activeWatch.elapsed.inSeconds;
        _activeWatch.stop();
        _activeWatch.reset();
        if (elapsed > 0) {
          _outbox.enqueueScreenDwell(
            routeName: _currentRoute,
            elapsedSeconds: elapsed,
          );
        }
        _outbox.enqueueLifecycleEvent('SESSION_END', routeName: _currentRoute);
        unawaited(_outbox.flushNow());
    }
  }
}
