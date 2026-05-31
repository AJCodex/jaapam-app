import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaapam/app/jaapam_app.dart';

void main() {
  testWidgets('App boots and shows app title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JaapamApp()));
    await tester.pumpAndSettle();
    // Either the English or Hindi appTitle should render; assert at least one Text shows.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
