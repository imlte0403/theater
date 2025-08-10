import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    // 프로덕션에서는 로깅 서비스로 전송
    _logError(details);
  }

  static void _logError(FlutterErrorDetails details) {
    // TODO: 실제 로깅 서비스 구현
    // Firebase Crashlytics, Sentry 등
    if (kDebugMode) {
      print('Error logged: ${details.exception}');
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}


