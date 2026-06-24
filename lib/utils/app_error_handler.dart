import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/app_error_banner.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static void setup() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log(details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log(error, stack);
      return true;
    };

    ErrorWidget.builder = (details) {
      return const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: AppErrorBanner(
              message: 'Something went wrong while loading this screen.',
            ),
          ),
        ),
      );
    };
  }

  static void log(Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('AppError: $error');
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }
  }

  static T runGuarded<T>(T Function() action, {T? fallback}) {
    try {
      return action();
    } catch (error, stack) {
      log(error, stack);
      if (fallback != null) return fallback;
      rethrow;
    }
  }

  static Future<T> runGuardedAsync<T>(
    Future<T> Function() action, {
    T? fallback,
  }) async {
    try {
      return await action();
    } catch (error, stack) {
      log(error, stack);
      if (fallback != null) return fallback;
      rethrow;
    }
  }
}
