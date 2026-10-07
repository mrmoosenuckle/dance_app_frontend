import 'package:dance_app_frontend/core/api_client.dart';
import 'package:dance_app_frontend/features/children/children_repository.dart';
import 'package:dance_app_frontend/features/children/landing_page.dart';
import 'package:dance_app_frontend/features/competitions/competitions_repository.dart';
import 'package:dance_app_frontend/features/dances/dances_repository.dart';
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
      return http.Response(
        posted == null
            ? '{"data":[],"meta":{"total":0}}'
            : '{"data":[{"id":"1","name":"Emilia Sullivan"}]}',
        200,
      );
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
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
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Emilia Sullivan'), findsOneWidget);
  });

  testWidgets('adds another child when one exists', (tester) async {
    String? posted;
    final client = MockClient((req) async {
      if (req.method == 'POST') {
        posted = req.body;
        return http.Response('{}', 201);
      }
      return http.Response(
        posted == null
            ? '{"data":[{"id":"1","name":"Emilia Sullivan"}]}'
            : '{"data":[{"id":"1","name":"Emilia Sullivan"},'
                  '{"id":"2","name":"Oscar Sullivan"}]}',
        200,
      );
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add another child'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Oscar Sullivan');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(posted, '{"name":"Oscar Sullivan"}');
    expect(find.text('Emilia Sullivan'), findsOneWidget);
    expect(find.text('Oscar Sullivan'), findsOneWidget);
  });

  testWidgets('deletes a child by id', (tester) async {
    Uri? deleted;
    final client = MockClient((req) async {
      if (req.method == 'DELETE') {
        deleted = req.url;
        return http.Response('', 204);
      }
      return http.Response(
        '{"data":[{"id":"abc","name":"Emilia Sullivan"}]}',
        200,
      );
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(deleted, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(deleted, isNull);
    expect(find.text('Emilia Sullivan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleted?.path, '/api/children/abc');
    expect(find.text('Emilia Sullivan'), findsNothing);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('child opens calendar with menu and can switch child', (
    tester,
  ) async {
    final client = MockClient(
      (_) async =>
          http.Response('{"data":[{"id":"1","name":"Emilia Sullivan"}]}', 200),
    );
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Emilia Sullivan'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    for (final t in ['Competitions', 'Dances', 'Costumes', 'Switch Child']) {
      expect(find.text(t), findsOneWidget);
    }

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Switch Child'), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Costumes'));
    await tester.pumpAndSettle();
    expect(find.text('Costumes coming soon'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch Child'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(find.text('Add another child'), findsOneWidget);
  });

  testWidgets('adds a dance from the dances page', (tester) async {
    Uri? url;
    String? body;
    final client = MockClient((req) async {
      if (req.method == 'POST') {
        url = req.url;
        body = req.body;
        return http.Response('{}', 201);
      }
      if (req.url.path == '/api/children/1/dances') {
        return http.Response(
          '[{"id":"d1","name":"One of a Kind","category":"Solo - Modern",'
          '"durationSeconds":90,"children":[]}]',
          200,
        );
      }
      return http.Response(
        '{"data":[{"id":"1","name":"Emilia Sullivan"},'
        '{"id":"2","name":"Oscar Sullivan"}]}',
        200,
      );
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Emilia Sullivan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dances'));
    await tester.pumpAndSettle();
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('One of a Kind'), findsOneWidget);
    expect(find.text('Solo - Modern'), findsOneWidget);
    expect(find.text('1:30'), findsOneWidget);

    await tester.tap(find.text('Add dance'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Swan Lake');
    await tester.enterText(fields.at(1), 'Ballet');
    await tester.enterText(fields.at(2), '120');
    await tester.tap(find.text('Oscar Sullivan'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(url?.path, '/api/dances');
    expect(
      body,
      '{"name":"Swan Lake","category":"Ballet","durationSeconds":120,'
      '"childIds":["1","2"]}',
    );
    expect(find.text('Dance added'), findsOneWidget);
  });

  testWidgets('shows message when child has no dances', (tester) async {
    final client = MockClient(
      (req) async => req.url.path.endsWith('/dances')
          ? http.Response('[]', 200)
          : http.Response(
              '{"data":[{"id":"1","name":"Emilia Sullivan"}]}',
              200,
            ),
    );
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emilia Sullivan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dances'));
    await tester.pumpAndSettle();

    expect(find.text('No current dances'), findsOneWidget);
    expect(find.text('Add dance'), findsOneWidget);
  });

  testWidgets('adds a competition for the selected child', (tester) async {
    Uri? url;
    String? body;
    final client = MockClient((req) async {
      if (req.method == 'POST') {
        url = req.url;
        body = req.body;
        return http.Response('{}', 201);
      }
      return http.Response(
        '{"data":[{"id":"1","name":"Emilia Sullivan"},'
        '{"id":"2","name":"Oscar Sullivan"}]}',
        200,
      );
    });
    final repo = ChildrenRepository(ApiClient(client: client));
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          repository: repo,
          dancesRepository: DancesRepository(ApiClient(client: client)),
          competitionsRepository: CompetitionsRepository(
            ApiClient(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emilia Sullivan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Competitions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add competition'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Spring Festival');
    await tester.enterText(fields.at(1), 'Town Hall');

    await tester.tap(find.text('Oscar Sullivan'));
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(url?.path, '/api/competitions');
    expect(body, contains('"name":"Spring Festival"'));
    expect(body, contains('"venue":"Town Hall"'));
    expect(body, contains('"childIds":["1","2"]'));
    expect(body, matches(RegExp(r'"date":"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ"')));
    expect(find.text('Competition added'), findsOneWidget);
  });
}
