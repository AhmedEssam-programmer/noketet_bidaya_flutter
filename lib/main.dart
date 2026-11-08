import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'services/supabase_client.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stack),
        );
        return true;
      };

      await _initializeSupabaseSafely();

      runApp(const ProviderScope(child: NoketetBidayaApp()));
    },
    (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    },
  );
}

Future<void> _initializeSupabaseSafely() async {
  try {
    await Supabase.initialize(
      url: AppSupabase.url,
      anonKey: AppSupabase.anonKey,
    ).timeout(const Duration(seconds: 12));
  } catch (error, stack) {
    // Keep the app usable offline; auth/sync services handle unavailable Supabase.
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
  }
}
