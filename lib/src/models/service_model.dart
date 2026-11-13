part of '../app.dart';

class ServiceItem {
  const ServiceItem({
    required this.icon,
    required this.label,
    required this.services,
  });

  final IconData icon;
  final String label;
  final String services;
}
