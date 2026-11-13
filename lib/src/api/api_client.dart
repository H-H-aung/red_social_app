part of '../app.dart';

class ApiResult<T> {
  const ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
}

class ApiClient {
  const ApiClient({http.Client? client}) : _client = client;

  final http.Client? _client;

  http.Client get client => _client ?? http.Client();

  Future<ApiResult<Map<String, dynamic>>> get(
    String route, {
    Map<String, String>? queryParameters,
  }) async {
    return _send(
      () => client.get(
        ApiConfig.route(route, queryParameters: queryParameters),
        headers: _headers(),
      ),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> postForm(
    String route,
    Map<String, String> body,
  ) async {
    return _send(
      () => client.post(ApiConfig.route(route), headers: _headers(), body: body),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> postJson(
    String route,
    Map<String, dynamic> body,
  ) async {
    return _send(
      () => client.post(
        ApiConfig.route(route),
        headers: _headers(contentType: 'application/json'),
        body: jsonEncode(body),
      ),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> postMultipart(
    String route, {
    required Map<String, String> fields,
    http.MultipartFile? file,
  }) async {
    return _send(() async {
      final request = http.MultipartRequest('POST', ApiConfig.route(route));
      request.headers.addAll(_headers());
      request.fields.addAll(fields);
      if (file != null) request.files.add(file);
      final streamed = await request.send().timeout(const Duration(seconds: 25));
      return http.Response.fromStream(streamed);
    });
  }

  Map<String, String> _headers({String? contentType}) {
    final headers = <String, String>{'Accept': 'application/json'};
    final token = UserSession.user?.token ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    return headers;
  }

  Future<ApiResult<Map<String, dynamic>>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(const Duration(seconds: 60));
      final body = response.body.trim();
      if (body.isEmpty) {
        return ApiResult(
          success: false,
          message: 'Empty API response. HTTP ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }

      final Object? decoded;
      try {
        decoded = jsonDecode(_stripBom(body));
      } on FormatException {
        return ApiResult(
          success: false,
          message: _invalidJsonMessage(response.statusCode, body),
          statusCode: response.statusCode,
        );
      }

      if (decoded is! Map<String, dynamic>) {
        return ApiResult(
          success: false,
          message: 'Invalid API response.',
          statusCode: response.statusCode,
        );
      }

      return ApiResult(
        success: decoded['success'] == true && response.statusCode < 400,
        message: decoded['message']?.toString() ?? 'Request completed.',
        data: decoded,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return const ApiResult(success: false, message: 'Request timed out.');
    } catch (error) {
      return ApiResult(success: false, message: error.toString());
    }
  }

  String _stripBom(String value) {
    return value.startsWith('\uFEFF') ? value.substring(1) : value;
  }

  String _invalidJsonMessage(int statusCode, String body) {
    final compact = body.replaceAll(RegExp(r'\s+'), ' ');
    final preview = compact.length > 90
        ? '${compact.substring(0, 90)}...'
        : compact;
    final looksLikeHtml =
        compact.startsWith('<!DOCTYPE') || compact.startsWith('<html');
    if (looksLikeHtml) {
      return 'Server returned HTML instead of JSON. HTTP $statusCode.';
    }
    return 'Invalid JSON response. HTTP $statusCode: $preview';
  }
}
