import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper over [FirebaseAnalytics] for the five product events we care
/// about, plus a generic [logError] forwarded from the global error handlers
/// (since Crashlytics has no Flutter-web support yet).
///
/// All methods swallow analytics failures — observability must never crash
/// the app. In debug mode events are also printed for quick verification.
class Analytics {
  Analytics(this._fa);
  final FirebaseAnalytics _fa;

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params ?? {}}');
    }
    try {
      await _fa.logEvent(name: name, parameters: params);
    } catch (_) {
      // Swallow: telemetry must never throw.
    }
  }

  Future<void> signIn(String method) => _log('login', {'method': method});

  Future<void> jaapAdded({required int count, required String mantra}) =>
      _log('jaap_added', {'count': count, 'mantra': mantra});

  Future<void> targetSet(int target) => _log('target_set', {'target': target});

  Future<void> campaignStarted({required int goal}) =>
      _log('campaign_started', {'goal': goal});

  Future<void> campaignContributed(int count) =>
      _log('campaign_contributed', {'count': count});

  /// Forwarded from `FlutterError.onError` / `PlatformDispatcher.onError`.
  Future<void> logError(Object error, StackTrace? stack, {bool fatal = false}) {
    final desc = error.toString();
    return _log('app_exception', {
      'message': desc.length > 100 ? desc.substring(0, 100) : desc,
      'fatal': fatal ? 1 : 0,
    });
  }
}

/// Singleton-style accessor wired in `main.dart` after Firebase init.
/// We keep a top-level mutable to avoid threading a Riverpod ref through
/// services like `JaapService` (which are constructed before any provider
/// is read). Tests can override via [setAnalyticsForTesting].
Analytics analytics = Analytics(FirebaseAnalytics.instance);

@visibleForTesting
void setAnalyticsForTesting(Analytics override) {
  analytics = override;
}
