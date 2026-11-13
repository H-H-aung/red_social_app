part of '../../app.dart';

class MobileLegendsPage extends StatelessWidget { const MobileLegendsPage({super.key}); @override Widget build(BuildContext context) => const _UnavailableGamePage(title: 'Mobile Legends'); }
class _UnavailableGamePage extends StatelessWidget { const _UnavailableGamePage({required this.title}); final String title; @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Service is coming soon.'))); }
