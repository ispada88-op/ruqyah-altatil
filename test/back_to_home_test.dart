import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:roqia_altatil/widgets/back_to_home_scope.dart';

/// يثبّت سلوك زر الرجوع في أندرويد: خارج الرئيسية يعود إلى الرئيسية، ويُبلَّغ
/// النظام أن Flutter يتولّى الرجوع (وإلا أغلق النظام التطبيق دون أن يصلنا شيء).
void main() {
  late List<bool> handlesBack;

  setUp(() => handlesBack = <bool>[]);

  GoRouter buildRouter() {
    Page<void> page(GoRouterState s, String label) => NoTransitionPage<void>(
        key: s.pageKey, child: Center(child: Text(label)));
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => BackToHomeScope(
            atHome: state.uri.path == '/',
            onBackToHome: () => context.go('/'),
            child: Scaffold(body: child),
          ),
          routes: [
            GoRoute(path: '/', pageBuilder: (c, s) => page(s, 'home')),
            GoRoute(path: '/tab', pageBuilder: (c, s) => page(s, 'tab')),
            GoRoute(path: '/other', pageBuilder: (c, s) => page(s, 'other')),
            GoRoute(path: '/pushed', pageBuilder: (c, s) => page(s, 'pushed')),
          ],
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester, GoRouter router) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
          handlesBack.add(call.arguments as bool);
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    // المحرّك لا يُحدَّث قبل أن يصير التطبيق جاهزاً.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('خارج الرئيسية: الرجوع يعيد إلى الرئيسية ولا يُغلق',
      (tester) async {
    final router = buildRouter();
    await pumpApp(tester, router);
    expect(find.text('home'), findsOneWidget);

    router.go('/tab');
    await tester.pumpAndSettle();
    expect(find.text('tab'), findsOneWidget);
    // النظام يعرف أن Flutter سيعالج الرجوع (وإلا أغلق التطبيق مباشرة).
    expect(handlesBack.last, isTrue);

    await systemBack(tester);
    expect(find.text('home'), findsOneWidget);
    expect(router.state.uri.path, '/');
  });

  testWidgets('من تبويب إلى آخر ثم رجوع: إلى الرئيسية', (tester) async {
    final router = buildRouter();
    await pumpApp(tester, router);
    router.go('/tab');
    await tester.pumpAndSettle();
    router.go('/other');
    await tester.pumpAndSettle();
    expect(handlesBack.last, isTrue);

    await systemBack(tester);
    expect(router.state.uri.path, '/');
  });

  testWidgets('في الرئيسية: الرجوع للنظام (يغلق التطبيق)', (tester) async {
    final router = buildRouter();
    await pumpApp(tester, router);
    router.go('/tab');
    await tester.pumpAndSettle();
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(handlesBack.last, isFalse);
  });

  testWidgets('صفحة مدفوعة بـ push: الرجوع يفتح ما قبلها لا الرئيسية',
      (tester) async {
    final router = buildRouter();
    await pumpApp(tester, router);
    router.go('/tab');
    await tester.pumpAndSettle();
    router.push('/pushed');
    await tester.pumpAndSettle();
    expect(find.text('pushed'), findsOneWidget);

    await systemBack(tester);
    expect(find.text('tab'), findsOneWidget);
    expect(router.state.uri.path, '/tab');
  });
}
