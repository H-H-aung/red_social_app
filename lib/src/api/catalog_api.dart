part of '../app.dart';

class CatalogApi {
  const CatalogApi({this.client = const ApiClient()});

  static List<ApiServiceProduct>? _servicesCache;
  static List<ApiGameProduct>? _gameProductsCache;

  final ApiClient client;

  static List<ApiServiceProduct>? get cachedServices => _servicesCache;

  static List<ApiGameProduct>? get cachedGameProducts => _gameProductsCache;

  static void warmUp() {
    const CatalogApi().services();
    const CatalogApi().gameProducts();
  }

  Future<ApiResult<List<ApiServiceProduct>>> services({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _servicesCache?.isNotEmpty == true) {
      return ApiResult(
        success: true,
        message: 'Services loaded from cache.',
        data: _servicesCache,
      );
    }

    final result = await client.get('services/catalog');
    final services = _readList(
      result.data,
      'services',
    ).map(ApiServiceProduct.fromJson).toList();
    if (services.isNotEmpty) {
      _servicesCache = services;
    }

    return ApiResult(
      success: result.success || _servicesCache?.isNotEmpty == true,
      message: result.message,
      statusCode: result.statusCode,
      data: services.isNotEmpty ? services : _servicesCache,
    );
  }

  Future<ApiResult<List<ApiGameProduct>>> gameProducts({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _gameProductsCache?.isNotEmpty == true) {
      return ApiResult(
        success: true,
        message: 'Game products loaded from cache.',
        data: _gameProductsCache,
      );
    }

    final result = await client.get('game-products/catalog');
    final products = _readList(
      result.data,
      'products',
    ).map(ApiGameProduct.fromJson).toList();
    if (products.isNotEmpty) {
      _gameProductsCache = products;
    }

    return ApiResult(
      success: result.success || _gameProductsCache?.isNotEmpty == true,
      message: result.message,
      statusCode: result.statusCode,
      data: products.isNotEmpty ? products : _gameProductsCache,
    );
  }

  List<Map<String, dynamic>> _readList(
    Map<String, dynamic>? response,
    String key,
  ) {
    final data = response?['data'];
    if (data is List) return _flattenItems(data, key);
    if (data is! Map) return const [];
    final raw = data[key];
    if (raw is! List) return const [];
    return _flattenItems(raw, key);
  }

  /// The catalog API groups products by category, for example:
  /// `data.services: [{category: ..., services: [...]}]`.
  /// Convert those groups into the flat list expected by the UI.
  List<Map<String, dynamic>> _flattenItems(List rawItems, String childKey) {
    final items = <Map<String, dynamic>>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) continue;
      final item = Map<String, dynamic>.from(rawItem);
      final children = item[childKey];
      if (children is List) {
        items.addAll(_flattenItems(children, childKey));
      } else {
        items.add(item);
      }
    }
    return items;
  }
}

class ApiServiceProduct {
  const ApiServiceProduct({
    required this.id,
    required this.category,
    required this.name,
    required this.rate,
    required this.min,
    required this.max,
    required this.averageTime,
    required this.description,
    required this.serviceGroup,
    required this.serviceType,
    required this.sellPriceMmk,
    required this.sellingRateMmk,
    required this.priceLabel,
    required this.pricePercent,
    required this.exchangeRate,
    required this.sellingRateUsd,
  });

  final int id;
  final String category;
  final String name;
  final double rate;
  final int min;
  final int max;
  final String averageTime;
  final String description;
  final String serviceGroup;
  final String serviceType;
  final double sellPriceMmk;
  final double sellingRateMmk;
  final String priceLabel;
  final double pricePercent;
  final double exchangeRate;
  final double sellingRateUsd;

  factory ApiServiceProduct.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'];
    final pricePercent = _toDouble(
      json['price_percent'] ??
          json['price_percentage'] ??
          json['pricePercent'] ??
          json['percent'] ??
          (pricing is Map<String, dynamic>
              ? pricing['price_percent'] ??
                    pricing['price_percentage'] ??
                    pricing['percent']
              : null),
    );
    final exchangeRate = _toDouble(
      json['exchange_rate'] ??
          json['custom_exchange_rate'] ??
          json['usd_to_mmk'] ??
          json['mmk_rate'] ??
          (pricing is Map<String, dynamic>
              ? pricing['exchange_rate'] ??
                    pricing['pricing_exchange_rate'] ??
                    pricing['customer_exchange_rate'] ??
                    pricing['api_exchange_rate'] ??
                    pricing['usd_to_mmk'] ??
                    pricing['mmk_rate']
              : null),
    );
    final sellPriceMmk = _toDouble(
      json['sell_price_mmk'] ??
          json['price_mmk'] ??
          json['rate_mmk'] ??
          (pricing is Map<String, dynamic>
              ? pricing['sell_price_mmk'] ??
                    pricing['price_mmk'] ??
                    pricing['selling_rate_mmk_per_1k'] ??
                    pricing['price_mmk_per_1k'] ??
                    pricing['rate_mmk']
              : null),
    );
    final sellingRateMmk = _toDouble(
      json['selling_rate_mmk'] ??
          json['selling_rate_mmk_per_1k'] ??
          json['selling_mmk'] ??
          (pricing is Map<String, dynamic>
              ? pricing['selling_rate_mmk'] ??
                    pricing['selling_rate_mmk_per_1k'] ??
                    pricing['selling_mmk']
              : null),
    );
    final sellingRateUsd = _toDouble(
      json['selling_rate'] ??
          json['selling_rate_per_1k'] ??
          json['selling_rate_usd'] ??
          json['selling_rate_usd_per_1k'] ??
          json['base_rate'] ??
          json['base_rate_usd'] ??
          (pricing is Map<String, dynamic>
              ? pricing['selling_rate'] ??
                    pricing['selling_rate_usd'] ??
                    pricing['selling_rate_usd_per_1k'] ??
                    pricing['base_rate'] ??
                    pricing['base_rate_usd']
              : null),
    );
    return ApiServiceProduct(
      id: _toInt(json['id'] ?? json['service_id'] ?? json['service']),
      category: (json['category'] ?? '').toString(),
      name: (json['name'] ?? json['service_name'] ?? '').toString(),
      rate: _toDouble(
        json['database_rate'] ??
            json['database_rate_per_1k'] ??
            json['api_rate'] ??
            json['api_rate_per_1k'] ??
            json['rate'] ??
            json['price'] ??
            (pricing is Map<String, dynamic>
                ? pricing['database_rate'] ??
                      pricing['database_rate_per_1k'] ??
                      pricing['api_rate'] ??
                      pricing['api_rate_per_1k'] ??
                      pricing['selling_rate_usd_per_1k']
                : null) ??
            json['usd_rate'],
      ),
      min: _toInt(json['min'] ?? json['minimum']),
      max: _toInt(json['max'] ?? json['maximum']),
      averageTime: (json['average_time'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      serviceGroup:
          (json['service_group'] ??
                  json['group'] ??
                  json['service_group_key'] ??
                  (pricing is Map<String, dynamic>
                      ? pricing['service_group'] ?? pricing['group']
                      : null) ??
                  '')
              .toString(),
      serviceType:
          (json['service_type'] ??
                  json['manual_service_type'] ??
                  json['manual_type'] ??
                  json['manual_type_name'] ??
                  json['type'] ??
                  '')
              .toString(),
      sellPriceMmk: sellPriceMmk,
      sellingRateMmk: sellingRateMmk,
      priceLabel: _servicePriceLabel(json, pricing),
      pricePercent: pricePercent,
      exchangeRate: exchangeRate,
      sellingRateUsd: sellingRateUsd,
    );
  }
}

String _servicePriceLabel(Map<String, dynamic> json, Object? pricing) {
  final raw = _firstNonEmpty([
    json['display_price'],
    json['price_label'],
    json['rate_label'],
    if (pricing is Map<String, dynamic>) ...[
      pricing['display_price'],
      pricing['price_label'],
      pricing['rate_label'],
    ],
  ]);
  if (raw.isEmpty) return '';
  return raw.startsWith(r'$') || raw.toUpperCase().contains('MMK')
      ? raw
      : raw;
}

String _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

class ApiGameProduct {
  const ApiGameProduct({
    required this.id,
    required this.gameKey,
    required this.gameName,
    required this.category,
    required this.productName,
    required this.baseRate,
    required this.sellPriceMmk,
    required this.fieldsRequired,
    required this.averageTime,
    required this.description,
  });

  final int id;
  final String gameKey;
  final String gameName;
  final String category;
  final String productName;
  final double baseRate;
  final double sellPriceMmk;
  final List<String> fieldsRequired;
  final String averageTime;
  final String description;

  factory ApiGameProduct.fromJson(Map<String, dynamic> json) {
    return ApiGameProduct(
      id: _toInt(json['id']),
      gameKey: (json['game_key'] ?? '').toString(),
      gameName: (json['game_name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      productName: (json['product_name'] ?? '').toString(),
      baseRate: _toDouble(json['base_rate']),
      sellPriceMmk: _toDouble(json['sell_price_mmk']),
      fieldsRequired: (json['fields_required'] ?? '')
          .toString()
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      averageTime: (json['average_time'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final text =
      value?.toString().replaceAll(',', '').replaceAll('%', '').replaceAll(r'$', '').trim() ??
      '';
  return double.tryParse(text) ?? 0;
}

String _normalizedManualType(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
}

bool _isTikTokPromoteService(ApiServiceProduct service) {
  final group = _normalizedManualType(service.serviceGroup);
  if (group == 'tiktok_promote') return true;
  if (group.isNotEmpty) return false;
  final type = _normalizedManualType(service.serviceType);
  return type == 'tiktok_promote' ||
      type == 'tik_tok_promote' ||
      type.contains('tiktok_promote') ||
      type.contains('tik_tok_promote');
}

bool _isPremiumService(ApiServiceProduct service) {
  final group = _normalizedManualType(service.serviceGroup);
  if (group == 'premium_services' || group == 'premium') return true;
  if (group.isNotEmpty) return false;
  final type = _normalizedManualType(service.serviceType);
  return type == 'premium_service' ||
      type == 'premium_servic' ||
      type == 'premium' ||
      type.contains('premium');
}

bool _isNormalSmmService(ApiServiceProduct service) {
  final group = _normalizedManualType(service.serviceGroup);
  if (group == 'smm' || group == 'normal' || group == 'normal_services') {
    return true;
  }
  if (group.isNotEmpty) return false;
  final type = _normalizedManualType(service.serviceType);
  if (_isTikTokPromoteService(service) || _isPremiumService(service)) {
    return false;
  }
  return type.isEmpty ||
      type == 'normal' ||
      type == 'normal_service' ||
      type == 'smm' ||
      type == 'smm_service';
}
