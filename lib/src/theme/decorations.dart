part of '../app.dart';

BoxDecoration _panelDecoration() => BoxDecoration(color: const Color(0xFF111722), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF253044)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .24), blurRadius: 18, offset: const Offset(0, 8))]);
BoxDecoration _loginPanelDecoration() => _panelDecoration().copyWith(border: Border.all(color: const Color(0xFFE71F32).withValues(alpha: .45)));
BoxDecoration _inputShadowDecoration() => BoxDecoration(color: const Color(0xFF0D131D), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF293346)));
BoxDecoration _miniBadgeDecoration(Color color) => BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: .45)));
Color _platformColor(String name) { final v = name.toLowerCase(); if (v.contains('facebook')) return const Color(0xFF1877F2); if (v.contains('youtube')) return const Color(0xFFFF0000); if (v.contains('tiktok')) return const Color(0xFF00C2D4); return const Color(0xFFE71F32); }
