import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('CRM App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CRMApp());
    expect(find.byType(MaterialApp), findsNothing);
  });
}
