import 'package:dance_app_frontend/core/api_client.dart';
import 'package:dance_app_frontend/features/children/children_repository.dart';
import 'package:dance_app_frontend/features/children/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('prompts for name when none exists, then shows it', (
    tester,
  ) async {
    String? posted;
    final client = MockClient((req) async {
      if (req.method == 'POST') {
        posted = req.body;
        return http.Response('{}', 201);
      }
      return http.Response('{"data":[],"meta":{"total":0}}', 200);
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(MaterialApp(home: LandingPage(repository: repo)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Emilia Sullivan');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(posted, '{"name":"Emilia Sullivan"}');
    expect(find.text('Emilia Sullivan'), findsOneWidget);
  });

  testWidgets('shows existing child', (tester) async {
    final client = MockClient(
      (_) async => http.Response(
        '{"data":[{"id":"1","name":"Emilia Sullivan"}],"meta":{"total":1}}',
        200,
      ),
    );
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(MaterialApp(home: LandingPage(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Emilia Sullivan'), findsOneWidget);
  });
}
