import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Capture unhandled errors outside the Flutter framework (e.g., Dart isolates)
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize core services here (e.g., local storage, environment variables)
    // await AppEnvironment.init();

    // Capture errors within the Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logGlobalError(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _logGlobalError(error, stack);
      return true;
    };

    runApp(
      // ProviderScope is mandatory for Riverpod to store application state
      const ProviderScope(
        child: PosApp(),
      ),
    );
  }, (error, stackTrace) {
    _logGlobalError(error, stackTrace);
  });
}

/// Global error logger. In production, connect this to Sentry, Crashlytics, or Datadog.
void _logGlobalError(Object error, StackTrace? stack) {
  debugPrint('CRITICAL ERROR: $error');
  if (stack != null) {
    debugPrint('STACK TRACE: $stack');
  }
}