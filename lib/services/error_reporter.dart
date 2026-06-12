import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// طبقة حماية مركزية للتطبيق:
///
/// 1. التقاط أخطاء Flutter (`FlutterError.onError`)
/// 2. التقاط أخطاء Dart غير المعالجة (`PlatformDispatcher.instance.onError`)
/// 3. التقاط أخطاء async داخل `runZonedGuarded`
/// 4. توفير `ErrorBoundary` widget يحمي شجرة widgets من الانهيار
/// 5. عرض رسالة لطيفة للمستخدم بدل شاشة Flutter الحمراء
///
/// الاستخدام في main():
/// ```dart
/// await ErrorReporter.runGuarded(() async {
///   runApp(const MyApp());
/// });
/// ```
class ErrorReporter {
  ErrorReporter._();

  static final List<LoggedError> _recentErrors = [];
  static const int _maxStored = 20;

  /// كل الأخطاء المسجّلة في الجلسة (للعرض في صفحة Debug إذا لزم).
  static List<LoggedError> get recentErrors => List.unmodifiable(_recentErrors);

  /// Initialize error capture. Call from main() BEFORE runApp().
  static void initialize() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError(
        details.exception,
        details.stack,
        context: details.context?.toString(),
        library: details.library,
      );
      if (kDebugMode) FlutterError.dumpErrorToConsole(details);
    };

    // Platform / Dart unhandled errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _logError(error, stack, library: 'platform');
      return true; // we handled it
    };
  }

  /// Run app inside a guarded zone that catches stray async errors.
  static Future<void> runGuarded(FutureOr<void> Function() body) async {
    initialize();
    await runZonedGuarded<Future<void>>(() async {
      await body();
    }, (error, stack) {
      _logError(error, stack, library: 'zone');
    });
  }

  /// Manual error logging (use inside try-catch where appropriate).
  static void report(Object error, StackTrace? stack, {String? context}) {
    _logError(error, stack ?? StackTrace.current, context: context);
  }

  static void _logError(
    Object error,
    StackTrace? stack, {
    String? context,
    String? library,
  }) {
    final entry = LoggedError(
      error: error.toString(),
      stack: stack?.toString() ?? 'no stack',
      context: context,
      library: library,
      timestamp: DateTime.now(),
    );

    _recentErrors.add(entry);
    if (_recentErrors.length > _maxStored) {
      _recentErrors.removeRange(0, _recentErrors.length - _maxStored);
    }

    if (kDebugMode) {
      debugPrint('🔴 [ErrorReporter] ${entry.error}');
      if (context != null) debugPrint('   context: $context');
      if (library != null) debugPrint('   library: $library');
    }
  }
}

class LoggedError {
  final String error;
  final String stack;
  final String? context;
  final String? library;
  final DateTime timestamp;

  LoggedError({
    required this.error,
    required this.stack,
    this.context,
    this.library,
    required this.timestamp,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// ErrorBoundary widget
// ═══════════════════════════════════════════════════════════════════════════

/// يلتف حول widget لحمايته من الانهيار. لو حصل خطأ في widget الابن،
/// نعرض fallback بدل شاشة الخطأ الحمراء.
///
/// Usage:
/// ```dart
/// ErrorBoundary(
///   child: SomePotentiallyBuggyWidget(),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? fallbackBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  @override
  void initState() {
    super.initState();
    // Replace ErrorWidget with our handler so red screens don't reach the user.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      ErrorReporter.report(details.exception, details.stack);
      return _DefaultFallback(error: details.exception, stack: details.stack);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder?.call(_error!, _stack) ??
          _DefaultFallback(error: _error!, stack: _stack);
    }
    return widget.child;
  }
}

class _DefaultFallback extends StatelessWidget {
  final Object error;
  final StackTrace? stack;

  const _DefaultFallback({required this.error, this.stack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ غير متوقع',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'نعتذر، حصل خطأ أثناء عرض هذه الصفحة. الرجاء العودة وإعادة المحاولة.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('رجوع'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      '$error\n\n${stack ?? ""}',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
