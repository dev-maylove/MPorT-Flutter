import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiResponse {
  final int statusCode;
  final String body;
  final Map<String, dynamic>? json;

  ApiResponse({required this.statusCode, required this.body, this.json});

  bool get isOk => statusCode >= 200 && statusCode < 300;

  String get message {
    if (json != null) {
      final m = json!['message'];
      if (m is String && m.isNotEmpty) return m;
      final errors = json!['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    if (body.isNotEmpty && body.length < 200) return body;
    return 'HTTP $statusCode';
  }
}

class ApiClient {
  ApiClient({this.tokenProvider});

  final Future<String?> Function()? tokenProvider;

  /// Base URL efektif (dart-define API_BASE_URL).
  static String get effectiveBaseUrl {
    final base = ApiConfig.baseUrl;
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = effectiveBaseUrl;
    if (path.contains('?')) {
      final parts = path.split('?');
      final qp = <String, String>{...?query};
      for (final pair in parts[1].split('&')) {
        final kv = pair.split('=');
        if (kv.length == 2) {
          qp[Uri.decodeComponent(kv[0])] = Uri.decodeComponent(kv[1]);
        }
      }
      return Uri.parse('$base${parts[0]}')
          .replace(queryParameters: qp.isEmpty ? null : qp);
    }
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<ApiResponse> get(String path, {bool auth = false}) =>
      _send(() async {
        final headers = await _headers(auth: auth);
        return http
            .get(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 20));
      });

  Future<ApiResponse> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) =>
      _send(() async {
        final headers = await _headers(auth: auth);
        return http
            .post(
              _uri(path),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 25));
      });

  Future<ApiResponse> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) =>
      _send(() async {
        final headers = await _headers(auth: auth);
        return http
            .put(
              _uri(path),
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 25));
      });

  Future<ApiResponse> delete(String path, {bool auth = false}) =>
      _send(() async {
        final headers = await _headers(auth: auth);
        return http
            .delete(_uri(path), headers: headers)
            .timeout(const Duration(seconds: 20));
      });

  Future<ApiResponse> _send(Future<http.Response> Function() call) async {
    try {
      final res = await call();
      return _wrap(res);
    } on SocketException catch (e) {
      return ApiResponse(
        statusCode: 0,
        body:
            'Tidak bisa terhubung ke server (${effectiveBaseUrl}). '
            'Periksa WiFi/URL API. ${e.message}',
      );
    } on TimeoutException {
      return ApiResponse(
        statusCode: 0,
        body:
            'Timeout menghubungi server (${effectiveBaseUrl}). '
            'Coba lagi atau periksa koneksi.',
      );
    } on HandshakeException catch (e) {
      return ApiResponse(
        statusCode: 0,
        body: 'Gagal SSL/TLS ke server: ${e.message}',
      );
    } on http.ClientException catch (e) {
      return ApiResponse(
        statusCode: 0,
        body:
            'Koneksi gagal ke ${effectiveBaseUrl}: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(
        statusCode: 0,
        body: 'Error jaringan: $e',
      );
    }
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth && tokenProvider != null) {
      final t = await tokenProvider!();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }
    return h;
  }

  ApiResponse _wrap(http.Response res) {
    Map<String, dynamic>? j;
    try {
      final d = jsonDecode(res.body);
      if (d is Map<String, dynamic>) {
        j = d;
      } else if (d is Map) {
        j = Map<String, dynamic>.from(d);
      }
    } catch (_) {}
    return ApiResponse(statusCode: res.statusCode, body: res.body, json: j);
  }
}
