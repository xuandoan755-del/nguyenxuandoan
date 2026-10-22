import 'package:flutter_test/flutter_test.dart';
import 'package:nguyenxuandoan/main.dart';

void main() {
  testWidgets('App launches successfully test', (WidgetTester tester) async {
    await tester.pumpWidget(const BaoAnApp());
    expect(find.text('BẢO AN'), findsOneWidget);
  });
}
