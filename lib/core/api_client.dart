import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Shared HTTP client. All endpoints are relative to [baseUrl].
class ApiClient {
  static const String defaultBaseUrl = 'http://localhost:3000/api';

  final String baseUrl;
  final http.Client _http;

  ApiClient({this.baseUrl = defaultBaseUrl, http.Client? client})
    : _http = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> get(String path) async {
    final res = await _send(() => _http.get(_uri(path)));
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => _http.post(
        _uri(path),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    return _decode(res);
  }

  Future<void> delete(String path) async {
    await _send(() => _http.delete(_uri(path)));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final res = await request();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException('Request failed (${res.statusCode})');
      }
      return res;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Could not reach the server');
    }
  }

  dynamic _decode(http.Response res) =>
      res.body.trim().isEmpty ? null : jsonDecode(res.body);
}
