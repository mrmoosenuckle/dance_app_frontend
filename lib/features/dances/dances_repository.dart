import '../../core/api_client.dart';
import 'dance.dart';

class DancesRepository {
  static const _path = '/dances';
  final ApiClient _api;
  DancesRepository(this._api);

  Future<List<Dance>> fetchDancesForChild(String childId) async {
    final data = await _api.get(
      '/children/${Uri.encodeComponent(childId)}/dances',
    );
    return (data is List ? data : const [])
        .whereType<Map<String, dynamic>>()
        .where((m) => m['id'] != null && m['name'] is String)
        .map(Dance.fromJson)
        .toList();
  }

  Future<void> addDance({
    required String name,
    required String category,
    required int durationSeconds,
    required List<String> childIds,
  }) => _api.post(_path, {
    'name': name,
    'category': category,
    'durationSeconds': durationSeconds,
    'childIds': childIds,
  });
}
