import 'package:flutter_test/flutter_test.dart';
import 'package:boom_party_games/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const BoomApp());
    expect(find.text('BOOM!'), findsOneWidget);
  });
}
