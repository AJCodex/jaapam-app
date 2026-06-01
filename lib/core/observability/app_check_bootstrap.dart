import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// reCAPTCHA v3 site key for the production hosting domain.
/// Provide at build time:
///   `flutter build web --release --dart-define=APP_CHECK_KEY=YOUR_KEY`
/// If empty, App Check is left inactive (acceptable on dev where rules are
/// the primary defence and App Check enforcement is off).
const _appCheckKey = String.fromEnvironment('APP_CHECK_KEY', defaultValue: '');

Future<void> activateAppCheck() async {
  if (_appCheckKey.isEmpty) {
    if (kDebugMode) {
      debugPrint('[app-check] no APP_CHECK_KEY supplied; skipping activation');
    }
    return;
  }
  try {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(_appCheckKey),
    );
    if (kDebugMode) debugPrint('[app-check] activated');
  } catch (e) {
    debugPrint('[app-check] activate failed: $e');
  }
}
