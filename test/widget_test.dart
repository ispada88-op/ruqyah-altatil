import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roqia_altatil/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
