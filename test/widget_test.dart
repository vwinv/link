import 'package:flutter_test/flutter_test.dart';
import 'package:linkflutter/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Link app shows onboarding on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LinkApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Votre carte de visite,\ntoujours sur vous'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });
}
