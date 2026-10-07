import '../../core/api_client.dart';
import 'child.dart';

class ChildrenRepository {
  static const _path = '/children';
  final ApiClient _api;
  ChildrenRepository(this._api);

  Future<List<Child>> fetchChildren() async {
    final data = await _api.get(_path);
    final list = data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .where((m) => m['id'] != null && m['name'] is String)
        .map(Child.fromJson)
        .toList();
  }

  Future<void> addChild(String name) => _api.post(_path, {'name': name});

  Future<void> deleteChild(String id) =>
      _api.delete('$_path/${Uri.encodeComponent(id)}');
}
