part of '../app.dart';

class AppUser {
  const AppUser({required this.id, required this.username, required this.email, required this.balance, required this.spent, required this.role, required this.discountPercent, this.token = '', this.phone = '', this.orders = 0});
  final int id;
  final String username;
  final String email;
  final double balance;
  final double spent;
  final String role;
  final double discountPercent;
  final String token;
  final String phone;
  final int orders;
  String get displayName => username.isEmpty ? email : username;
  AppUser copyWith({String? username, String? phone, String? token, double? balance, int? orders}) => AppUser(id: id, username: username ?? this.username, email: email, balance: balance ?? this.balance, spent: spent, role: role, discountPercent: discountPercent, token: token ?? this.token, phone: phone ?? this.phone, orders: orders ?? this.orders);
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(id: _toInt(json['id'] ?? json['user_id']), username: (json['username'] ?? json['name'] ?? '').toString(), email: (json['email'] ?? '').toString(), balance: _toDouble(json['balance']), spent: _toDouble(json['spent']), role: (json['role'] ?? 'user').toString(), discountPercent: _toDouble(json['discount_percent']), token: (json['token'] ?? json['access_token'] ?? '').toString(), phone: (json['phone'] ?? '').toString(), orders: _toInt(json['orders']));
}

class UserSession {
  UserSession._();
  static final current = ValueNotifier<AppUser?>(null);
  static AppUser? get user => current.value;
  static void clear() => current.value = null;
  static void saveFromApi(Map<String, dynamic>? data) {
    final payload = data?['data'] is Map<String, dynamic> ? data!['data'] as Map<String, dynamic> : data;
    if (payload == null) return;
    final userData = payload['user'] is Map<String, dynamic> ? payload['user'] as Map<String, dynamic> : payload;
    final token = (payload['token'] ?? payload['access_token'] ?? userData['token'] ?? '').toString();
    current.value = AppUser.fromJson(userData).copyWith(token: token);
  }
}
