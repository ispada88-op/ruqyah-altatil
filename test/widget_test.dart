import 'package:flutter_test/flutter_test.dart';
import 'package:roqia_altatil/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const RuqyahApp());
    await tester.pumpAndSettle();
  });
}
