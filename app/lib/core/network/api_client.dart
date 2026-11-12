import 'dart:convert';
import 'dart:io';

/// HTTP client ringan berbasis `dart:io` menuju backend NestJS (`/api/v1`).
///
/// Menangani:
/// - Resolusi host otomatis: `127.0.0.1:4100` (desktop / `adb reverse` HP fisik
///   atau emulator) dan `10.0.2.2:4100` (Android emulator default bridge).
/// - Header `x-company-id` untuk isolasi multi-perusahaan (PRD BR-10).
/// - Timeout cepat (`1200ms`) agar saat peranti benar-benar offline (mis. HP uji
///   tanpa internet/USB), repository langsung jatuh ke data fallback tanpa jeda
///   panjang.
class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();

  static const _candidates = <String>[
    'http://127.0.0.1:4100/api/v1',
    'http://10.0.2.2:4100/api/v1',
  ];

  String? _resolvedBase;
  String? accessToken;
  String? companyId;
  bool lastCallOnline = false;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _request('POST', path, body: body);

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) =>
      _request('PATCH', path, body: body);

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await post('/auth/login', body: {
      'email': email.trim().isEmpty ? 'owner@nusantara.co.id' : email.trim(),
      'password': password.isEmpty ? 'demo1234' : password,
    });
    if (res is Map<String, dynamic>) {
      accessToken = res['accessToken'] as String?;
      final user = res['user'];
      if (user is Map<String, dynamic>) {
        companyId = user['companyId'] as String?;
      }
      return res;
    }
    return null;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final bases = _resolvedBase != null
        ? <String>[
            _resolvedBase!,
            ..._candidates.where((c) => c != _resolvedBase),
          ]
        : _candidates;

    for (final base in bases) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 1200);
      try {
        var uri = Uri.parse('$base$path');
        if (query != null && query.isNotEmpty) {
          uri = uri.replace(queryParameters: query);
        }
        final req = await client
            .openUrl(method, uri)
            .timeout(const Duration(milliseconds: 1800));
        req.headers.set(HttpHeaders.acceptHeader, 'application/json');
        if (companyId != null && companyId!.isNotEmpty) {
          req.headers.set('x-company-id', companyId!);
        }
        if (accessToken != null && accessToken!.isNotEmpty) {
          req.headers
              .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
        }
        if (body != null) {
          final encoded = utf8.encode(jsonEncode(body));
          req.headers.set(
              HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
          req.contentLength = encoded.length;
          req.add(encoded);
        }
        final res =
            await req.close().timeout(const Duration(milliseconds: 2500));
        final text = await res.transform(utf8.decoder).join();
        if (res.statusCode >= 200 && res.statusCode < 300) {
          _resolvedBase = base;
          lastCallOnline = true;
          return text.isEmpty ? null : jsonDecode(text);
        }
      } catch (_) {
        // Coba kandidat berikutnya atau jatuh ke offline fallback di repository.
      } finally {
        client.close(force: true);
      }
    }
    lastCallOnline = false;
    return null;
  }
}
