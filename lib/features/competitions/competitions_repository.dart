import '../../core/api_client.dart';

class CompetitionsRepository {
  static const _path = '/competitions';
  final ApiClient _api;
  CompetitionsRepository(this._api);

  Future<void> addCompetition({
    required String name,
    required DateTime date,
    required String venue,
    required List<String> childIds,
  }) => _api.post(_path, {
    'name': name,
    'date': date.toUtc().toIso8601String().replaceFirst('.000', ''),
    'venue': venue,
    'childIds': childIds,
  });
}
