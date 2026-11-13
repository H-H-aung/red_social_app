part of '../app.dart';

class TicketsApi {
  const TicketsApi({this.client = const ApiClient()});
  final ApiClient client;
  Future<ApiResult<List<TicketItem>>> myTickets() async { final result = await client.get('tickets/my'); final raw = result.data?['data']; final rows = raw is List ? raw.whereType<Map<String, dynamic>>() : const Iterable<Map<String, dynamic>>.empty(); final tickets = rows.map((e) { final status = (e['status'] ?? 'Pending').toString(); return TicketItem(id: '#${e['id'] ?? '-'}', subject: (e['subject'] ?? e['message'] ?? 'Support ticket').toString(), status: status, time: shortRelativeTime((e['created_at'] ?? '').toString()), color: status.toLowerCase().contains('close') ? const Color(0xFF22C55E) : const Color(0xFFF59E0B)); }).toList(); return ApiResult(success: result.success, message: result.message, data: tickets, statusCode: result.statusCode); }
  Future<ApiResult<Map<String, dynamic>>> create({required String category, required String requestType, required String orderId, required String message}) => client.postForm('tickets/create', {'category': category, 'request_type': requestType, 'order_id': orderId, 'message': message});
}
