import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Playrium App initialization and welcome screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PlayriumApp(),
      ),
    );

    // Verify that GoRouter redirects to the welcome/login page and renders the app title
    expect(find.text('PLAYRIUM'), findsOneWidget);
  });
}
