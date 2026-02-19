import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_isolates/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Advanced Isolates'), findsNothing);
  });
}
