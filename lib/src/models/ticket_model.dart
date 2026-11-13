part of '../app.dart';

class TicketItem {
  const TicketItem({
    required this.id,
    required this.subject,
    required this.status,
    required this.color,
    this.time = '',
  });

  final String id;
  final String subject;
  final String status;
  final Color color;
  final String time;
}
