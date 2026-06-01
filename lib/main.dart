import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/jaapam_app.dart';
import 'core/observability/analytics.dart';
import 'core/observability/app_check_bootstrap.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await activateAppCheck();

    // Global Flutter framework errors → Analytics (Crashlytics has no web SDK).
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      analytics.logError(details.exception, details.stack, fatal: true);
    };
    // Uncaught platform errors (web, isolate boundaries).
    PlatformDispatcher.instance.onError = (error, stack) {
      analytics.logError(error, stack, fatal: true);
      return false;
    };

    runApp(const ProviderScope(child: JaapamApp()));
  }, (error, stack) {
    analytics.logError(error, stack, fatal: true);
  });
}
