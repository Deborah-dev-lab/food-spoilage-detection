import 'package:flutter_test/flutter_test.dart';
import 'package:food_spoilage/main.dart';

void main() {
  testWidgets('Food Spoilage Detection app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodSpoilageApp());

    expect(find.text('Food Spoilage Detection'), findsOneWidget);
    expect(find.text('Check the freshness of your food'), findsOneWidget);
  });
}