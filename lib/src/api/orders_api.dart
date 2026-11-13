part of '../app.dart';

class OrdersApi {
  const OrdersApi({this.client = const ApiClient()});

  final ApiClient client;

  Future<ApiResult<Map<String, dynamic>>> create({
    required int serviceId,
    required String link,
    required int quantity,
    String? comment,
  }) async {
    final payload = {
      'service_id': serviceId,
      'service': serviceId,
      'link': link,
      'quantity': quantity,
      'qty': quantity,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    };
    final result = await client.postJson('orders/create', payload);
    if (result.success || result.statusCode == 401 || result.statusCode == 402) {
      return result;
    }
    return client.postForm(
      'orders/create',
      payload.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createRaw(
    Map<String, dynamic> payload,
  ) {
    return client.postJson('orders/create', payload);
  }

  Future<ApiResult<Map<String, dynamic>>> createGame({
    required int userId,
    required int productId,
    required int quantity,
    required String playerId,
    String? zoneId,
    String? contact,
    String? note,
  }) {
    final payload = {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      if (playerId.trim().isNotEmpty) 'player_id': playerId.trim(),
      if (zoneId != null && zoneId.trim().isNotEmpty)
        'zone_id': zoneId.trim(),
      if (contact != null && contact.trim().isNotEmpty)
        'contact': contact.trim(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };
    return client.postForm(
      'game-orders/create',
      payload.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Future<ApiResult<List<OrderItem>>> myOrders() async {
    final result = await client.get('orders/my');
    final raw = result.data?['data'];
    final rows = raw is List
        ? raw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final orders = rows.map(_orderFromJson).toList();
    return ApiResult(
      success: result.success,
      message: result.message,
      statusCode: result.statusCode,
      data: orders,
    );
  }

  Future<ApiResult<List<OrderItem>>> gameOrders({required int userId}) async {
    final result = await client.get(
      'game-orders/my',
      queryParameters: {'user_id': userId.toString()},
    );
    final raw = result.data?['data'];
    final rows = raw is List
        ? raw.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final orders = rows.map(_gameOrderFromJson).toList();
    return ApiResult(
      success: result.success,
      message: result.message,
      statusCode: result.statusCode,
      data: orders,
    );
  }

  OrderItem _orderFromJson(Map<String, dynamic> json) {
    final title = (json['service_name'] ?? json['product_name'] ?? 'Order')
        .toString();
    final quantity = _toInt(json['quantity']);
    final status = (json['status'] ?? 'Pending').toString();
    final charge = _toDouble(json['charge']);
    final createdAt = (json['created_at'] ?? '').toString();
    return OrderItem(
      icon: _platformIcon(title),
      title: title,
      subtitle: quantity > 0 ? '$quantity quantity' : 'Order placed',
      id: '#${json['id'] ?? '-'}',
      time: _shortOrderTime(createdAt),
      price: _chargeLabel(charge, json),
      status: status,
      statusColor: _orderStatusColor(status),
    );
  }

  OrderItem _gameOrderFromJson(Map<String, dynamic> json) {
    final title =
        (json['product_name'] ?? json['name'] ?? json['game_name'] ?? 'Game')
            .toString();
    final gameName = (json['game_name'] ?? 'Game').toString();
    final category = (json['category'] ?? '').toString();
    final quantity = _toInt(json['quantity']);
    final playerId = (json['player_id'] ?? '').toString();
    final zoneId = (json['zone_id'] ?? '').toString();
    final status = (json['status'] ?? 'Pending').toString();
    final charge = _toDouble(json['charge'] ?? json['total']);
    final createdAt = (json['created_at'] ?? '').toString();
    final playerLabel = playerId.isEmpty
        ? ''
        : zoneId.isEmpty
            ? ' | ID $playerId'
            : ' | ID $playerId ($zoneId)';
    return OrderItem(
      icon: _platformIcon(gameName),
      title: '$gameName - $title',
      subtitle:
          '${category.isEmpty ? 'Game order' : category} | Qty $quantity$playerLabel',
      id: '#${json['id'] ?? '-'}',
      time: _shortOrderTime(createdAt),
      price: _chargeLabel(charge, json),
      status: status,
      statusColor: _orderStatusColor(status),
    );
  }

  String _chargeLabel(double charge, Map<String, dynamic> json) {
    final rawLabel =
        (json['charge_label'] ??
                json['display_charge'] ??
                json['amount_label'] ??
                json['display_amount'] ??
                '')
            .toString()
            .trim();
    if (rawLabel.isNotEmpty) {
      final upper = rawLabel.toUpperCase();
      if (rawLabel.startsWith(r'$') && upper.contains('MMK')) return rawLabel;
      if (rawLabel.startsWith(r'$')) {
        return '$rawLabel / ${_formatMmk(_chargeMmk(charge, json))} MMK';
      }
      if (upper.contains('MMK') || upper.contains('KS')) {
        return '${_formatUsd(charge)} / $rawLabel';
      }
    }

    return '${_formatUsd(charge)} / ${_formatMmk(_chargeMmk(charge, json))} MMK';
  }

  double _chargeMmk(double charge, Map<String, dynamic> json) {
    final mmk = _toDouble(
      json['charge_mmk'] ?? json['amount_mmk'] ?? json['total_mmk'],
    );
    if (mmk > 0) return mmk;
    return _usdToMmk(charge).toDouble();
  }

  String _formatUsd(double value) {
    return '\$${value.toStringAsFixed(4)}';
  }

  String _formatMmk(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write(',');
      buffer.write(rounded[i]);
    }
    return buffer.toString();
  }

  String _shortOrderTime(String value) {
    return shortRelativeTime(value);
  }

  Color _orderStatusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('complete')) return const Color(0xFF22C55E);
    if (value.contains('process')) return const Color(0xFFF59E0B);
    if (value.contains('cancel') || value.contains('reject')) {
      return const Color(0xFFE71F32);
    }
    return const Color(0xFF3B82F6);
  }
}
