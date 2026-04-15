import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder widget test', (WidgetTester tester) async {
    expect(find.text('not rendered yet'), findsNothing);
  });
}
