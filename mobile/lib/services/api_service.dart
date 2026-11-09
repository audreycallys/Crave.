import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.4:5000/api';
  static const String _tokenKey = 'token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<int?> getCurrentUserId() async {
    try {
      final token = await getToken();

      if (token == null) return null;

      final parts = token.split('.');

      if (parts.length != 3) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      if (payload is! Map<String, dynamic>) return null;

      return int.tryParse(payload['id'].toString());
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;

    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      throw Exception(
        'Server mengembalikan response yang bukan JSON '
        '(${response.statusCode}): ${response.body}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map ? body['message'] : null;

    throw Exception(
      message ?? 'Terjadi kesalahan pada server (${response.statusCode})',
    );
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  static MediaType _getMediaType(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.startsWith('image/')) {
      return MediaType.parse(mimeType);
    }

    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  static Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required Uint8List photoBytes,
    required String fileName,
    String? mimeType,
  }) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        photoBytes,
        filename: fileName,
        contentType: _getMediaType(fileName, mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  static Future<dynamic> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Uint8List? photoBytes,
    String? fileName,
    String? mimeType,
  }) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    if (photoBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: fileName,
          contentType: _getMediaType(fileName, mimeType),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  static Future<dynamic> getComments(String entryId) async {
    return get('/comments/entries/$entryId');
  }

  static Future<dynamic> createComment(String entryId, String content) async {
    return post('/comments/entries/$entryId', {'content': content});
  }

  static Future<dynamic> updateComment(String commentId, String content) async {
    return put('/comments/$commentId', {'content': content});
  }

  static Future<dynamic> deleteComment(String commentId) async {
    return delete('/comments/$commentId');
  }
}
