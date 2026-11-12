import 'dart:convert';
import 'package:http/http.dart' as http;

/// HTTP client lintas-platform (Android, iOS `.ipa`, & Web/Safari iOS PWA)
/// berbasis `package:http` menuju backend NestJS (`/api/v1`).
///
/// Menangani:
/// - Resolusi host otomatis: `127.0.0.1:4100` (desktop / iOS / `adb reverse`)
///   dan `10.0.2.2:4100` (Android emulator default bridge), atau URL server
///   kustom yang diatur lewat layar Login.
/// - Header `x-company-id` untuk isolasi multi-perusahaan (PRD BR-10).
/// - Timeout cepat (`1500ms`) agar saat peranti benar-benar offline (mis. HP
///   klien tanpa koneksi ke server), repository langsung jatuh ke data
///   fallback tanpa jeda panjang.
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

  String get currentBaseUrl => _resolvedBase ?? _candidates.first;

  void setCustomBaseUrl(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) {
      _resolvedBase = null;
      return;
    }
    var normalized =
        trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
    if (!normalized.endsWith('/api/v1')) {
      normalized = '$normalized/api/v1';
    }
    _resolvedBase = normalized;
  }

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
        // Backend mengirim perusahaan sebagai objek bersarang
        // (`user.company.id`). Bentuk datar `user.companyId` tetap diterima
        // supaya klien lama/baru sama-sama jalan.
        final company = user['company'];
        companyId = company is Map<String, dynamic>
            ? company['id'] as String?
            : user['companyId'] as String?;
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

    final headers = <String, String>{
      'Accept': 'application/json',
      if (companyId != null && companyId!.isNotEmpty)
        'x-company-id': companyId!,
      if (accessToken != null && accessToken!.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      if (body != null) 'Content-Type': 'application/json; charset=utf-8',
    };
    final encodedBody = body != null ? jsonEncode(body) : null;

    for (final base in bases) {
      try {
        var uri = Uri.parse('$base$path');
        if (query != null && query.isNotEmpty) {
          uri = uri.replace(queryParameters: query);
        }
        const timeout = Duration(milliseconds: 1500);
        final http.Response res = switch (method) {
          'POST' => await http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
          'PATCH' => await http
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(timeout),
          _ => await http.get(uri, headers: headers).timeout(timeout),
        };
        if (res.statusCode >= 200 && res.statusCode < 300) {
          _resolvedBase = base;
          lastCallOnline = true;
          final text = utf8.decode(res.bodyBytes);
          return text.isEmpty ? null : jsonDecode(text);
        }
      } catch (_) {
        // Coba kandidat berikutnya atau jatuh ke offline fallback di repository.
      }
    }
    lastCallOnline = false;
    return null;
  }
}
