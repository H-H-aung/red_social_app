import 'package:flutter_test/flutter_test.dart';

import 'package:smm/main.dart';

void main() {
  testWidgets('shows Red Site Social login UI', (WidgetTester tester) async {
    await tester.pumpWidget(const RedSiteSocialApp());

    expect(find.text('Red Site Social'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
