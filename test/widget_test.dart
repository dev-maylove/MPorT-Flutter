import 'package:flutter_test/flutter_test.dart';
import 'package:mport/main.dart';

void main() {
  testWidgets('MportApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MportApp());
    await tester.pump(); // first frame
    // App should build without throwing
    expect(tester.takeException(), isNull);
  });
}
