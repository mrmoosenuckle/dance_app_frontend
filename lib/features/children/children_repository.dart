import '../../core/api_client.dart';
import 'child.dart';

class ChildrenRepository {
  static const _path = '/children';
  final ApiClient _api;
  ChildrenRepository(this._api);

  /// Returns the first child, or null if none exist.
  Future<Child?> fetchChild() async {
    final data = await _api.get(_path);
    final list = data is Map && data['data'] is List
        ? data['data'] as List
        : const [];
    final items = list.whereType<Map<String, dynamic>>().where(
      (m) => m['name'] is String,
    );
    return items.isEmpty ? null : Child.fromJson(items.first);
  }

  Future<Child> addChild(String name) async {
    await _api.post(_path, {'name': name});
    return Child(name: name);
  }
}
