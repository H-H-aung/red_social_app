part of '../app.dart';

class WalletMethod {
  const WalletMethod({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.color,
    required this.status,
    required this.statusColor,
  });

  final String title;
  final String date;
  final String amount;
  final Color color;
  final String status;
  final Color statusColor;
}
