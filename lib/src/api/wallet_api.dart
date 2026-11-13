part of '../app.dart';

class WalletApi {
  const WalletApi({this.client = const ApiClient()});

  final ApiClient client;

  Future<ApiResult<List<WalletTransaction>>> transactions() async {
    final result = await client.get('wallet/transactions');
    final rows = _readRows(result.data);
    final transactions = rows.map(_transactionFromJson).toList();
    return ApiResult(
      success: result.success,
      message: result.message,
      statusCode: result.statusCode,
      data: transactions,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> submitTopUp({
    required double amount,
    required String transactionId,
    required String note,
    required XFile screenshot,
  }) async {
    final bytes = await screenshot.readAsBytes();
    final mimeType =
        lookupMimeType(screenshot.name, headerBytes: bytes) ?? 'image/jpeg';
    final mediaTypeParts = mimeType.split('/');
    final file = http.MultipartFile.fromBytes(
      'screenshot',
      bytes,
      filename: screenshot.name.isEmpty
          ? 'payment_screenshot.jpg'
          : screenshot.name,
      contentType: MediaType(mediaTypeParts.first, mediaTypeParts.last),
    );

    final result = await client.postMultipart(
      'payments/mmqr/upload',
      fields: {
        'amount': amount.toStringAsFixed(0),
        'transaction_id': transactionId,
        'reference': transactionId,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
      file: file,
    );
    if (result.statusCode == 404 &&
        result.message.toLowerCase().contains('endpoint not found')) {
      return ApiResult(
        success: false,
        message:
            'MMQR screenshot upload API endpoint is not available.',
        data: result.data,
        statusCode: result.statusCode,
      );
    }
    return result;
  }

  List<Map<String, dynamic>> _readRows(Map<String, dynamic>? response) {
    final data = response?['data'];
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is! Map<String, dynamic>) return const [];
    final raw = data['transactions'] ?? data['items'] ?? data['rows'];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  WalletTransaction _transactionFromJson(Map<String, dynamic> json) {
    final rawAmount = _toDouble(json['amount'] ?? json['charge']);
    final type = (json['type'] ?? json['transaction_type'] ?? '').toString();
    final title = (json['title'] ?? json['description'] ?? _titleFor(type, rawAmount)).toString();
    final signedAmount = _signedAmount(rawAmount, type);
    final status = _walletStatus((json['status'] ?? '').toString());
    final statusColor = _walletStatusColor(status);
    return WalletTransaction(
      title: title,
      date: _shortWalletTime((json['created_at'] ?? json['date'] ?? '').toString()),
      amount: _amountLabel(signedAmount, json),
      color: status.isEmpty
          ? (signedAmount < 0
                ? const Color(0xFFE71F32)
                : const Color(0xFF22C55E))
          : statusColor,
      status: status,
      statusColor: statusColor,
    );
  }

  String _walletStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'waiting_username':
      case 'waiting_photo':
      case 'completed':
      case 'pending':
        return 'Pending';
      default:
        return value.trim();
    }
  }

  Color _walletStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFE71F32);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _titleFor(String type, double amount) {
    final value = type.toLowerCase();
    if (value.contains('deposit') || value.contains('top')) return 'Deposit - MMQR';
    if (amount < 0 || value.contains('order')) return 'Order Payment';
    return 'Wallet Transaction';
  }

  double _signedAmount(double amount, String type) {
    final value = type.toLowerCase();
    if (value.contains('debit') || value.contains('order') || value.contains('withdraw')) {
      return -amount.abs();
    }
    return amount;
  }

  String _amountLabel(double amount, Map<String, dynamic> json) {
    final raw = (json['amount_label'] ?? json['display_amount'] ?? '').toString().trim();
    if (raw.isNotEmpty) return raw;
    final prefix = amount < 0 ? '-' : '+';
    return '$prefix ${amount.abs().round()} MMK';
  }

  String _shortWalletTime(String value) {
    return shortRelativeTime(value);
  }
}
