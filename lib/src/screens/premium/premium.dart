part of '../../app.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  static const _categories = <ServiceItem>[
    ServiceItem(icon: Icons.design_services_rounded, label: 'Canva', services: 'View plans'),
    ServiceItem(icon: Icons.movie_filter_rounded, label: 'Capcut', services: 'View plans'),
    ServiceItem(icon: Icons.workspace_premium_rounded, label: 'Premium', services: 'View plans'),
  ];

  @override
  Widget build(BuildContext context) {
    return _PageFrame(
      title: 'Premium Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Choose a category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          for (final category in _categories) ...[
            SizedBox(
              height: 112,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PremiumOrderFormPage(service: category))),
                  child: _PlatformCard(item: category),
                ),
              ),
            ),
            if (category != _categories.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
