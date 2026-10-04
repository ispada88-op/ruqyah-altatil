import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/nav.dart';

/// كل مسار معرَّف في AppRoutes.all مسجَّل فعلاً في الموجِّه (وبالعكس) — يلتقط
/// صفحة جديدة نُسي ربطها أو مساراً يتيماً بعد إعادة تسمية.
void main() {
  Iterable<String> paths(List<RouteBase> routes, [String prefix = '']) sync* {
    for (final r in routes) {
      if (r is GoRoute) {
        final full = r.path.startsWith('/')
            ? r.path
            : '${prefix == '/' ? '' : prefix}/${r.path}';
        yield full;
        yield* paths(r.routes, full);
      } else if (r is ShellRouteBase) {
        yield* paths(r.routes, prefix);
      }
    }
  }

  final registered = paths(AppRouter.router.configuration.routes).toSet();

  test('every canonical route has a registered page', () {
    for (final r in AppRoutes.all) {
      expect(registered, contains(r), reason: 'route $r is not registered');
    }
  });

  test('every registered fixed route is listed in AppRoutes.all', () {
    final fixed = registered.where((p) => !p.contains(':'));
    for (final p in fixed) {
      expect(AppRoutes.all, contains(p),
          reason: 'route $p missing from AppRoutes.all');
    }
  });

  test('parameterised pages are registered', () {
    expect(
        registered.any(
            (p) => p.startsWith('${AppRoutes.mushaf}/') && p.contains('page')),
        isTrue);
    expect(registered.any((p) => p.startsWith('${AppRoutes.ruqyahTypes}/')),
        isTrue);
  });
}
