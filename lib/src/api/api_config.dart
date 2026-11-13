part of '../app.dart';

class ApiConfig {
  const ApiConfig._();

  static const baseUrl = 'https://api.mmredsite.com/';

  static Uri route(String route, {Map<String, String>? queryParameters}) {
    return Uri.parse(
      baseUrl,
    ).replace(
      path: 'index.php',
      queryParameters: {'route': route, ...?queryParameters},
    );
  }
}
