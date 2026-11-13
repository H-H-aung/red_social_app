part of '../app.dart';

class OrderItem {
  const OrderItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.id,
    required this.time,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String id;
  final String time;
  final String price;
  final String status;
  final Color statusColor;
}
