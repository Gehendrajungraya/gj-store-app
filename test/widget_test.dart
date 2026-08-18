import 'package:flutter_test/flutter_test.dart';
import 'package:gj_store_app/main.dart';

void main() {
  testWidgets('GJ Store starts', (tester) async {
    await tester.pumpWidget(const GJStoreApp());
    expect(find.text('GJ STORE'), findsOneWidget);
  });
}
