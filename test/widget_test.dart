import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_spoilage/main.dart';

void main() {
  testWidgets('FreshTrack welcome screen loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FreshTrackApp());

    // Verify the application branding.
    expect(find.text('freshtrack.'), findsOneWidget);

    // Verify the welcome screen heading.
    expect(find.text('Fresh choices\nstart here.'), findsOneWidget);

    // Verify the introductory message.
    expect(find.textContaining('A simpler way to understand'), findsOneWidget);

    // Verify the onboarding button.
    expect(find.text('Get started'), findsOneWidget);

    // Verify that the welcome screen contains a button.
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
