part of '../../app.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageFrame(
      title: 'Game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GameCategorySection(
            title: 'Popular Game Service',
            subtitle: 'General top up and gift services',
            items: _GameItemsGrid.generalItems,
          ),
        ],
      ),
    );
  }
}

class _GameItemsGrid extends StatelessWidget {
  const _GameItemsGrid();

  static const smileOneItems = <ServiceItem>[];

  static const generalItems = [
    ServiceItem(icon: Icons.sports_esports, label: 'MLBB', services: '18'),
    ServiceItem(icon: Icons.extension, label: 'PUBG UC', services: '12'),
    ServiceItem(
      icon: Icons.local_fire_department_rounded,
      label: 'Free Fire',
      services: '6',
    ),
    ServiceItem(
      icon: Icons.workspace_premium_rounded,
      label: 'Honor of Kings',
      services: '10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _GameCategorySection(
      title: 'Game Services',
      subtitle: 'Choose a game service',
      items: [...smileOneItems, ...generalItems],
    );
  }
}

class _GameCategorySection extends StatelessWidget {
  const _GameCategorySection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<ServiceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7F8898),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in items) ...[
          SizedBox(height: 112, child: _GameItemTile(item: item)),
          if (item != items.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GameItemTile extends StatelessWidget {
  const _GameItemTile({required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.label == 'MLBB') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MobileLegendsPage()),
            );
            return;
          }

          if (item.label == 'PUBG UC') {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PubgPage()));
            return;
          }

          if (item.label == 'Free Fire') {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const FreeFirePage()));
            return;
          }

          if (item.label == 'Honor of Kings') {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HonorOfKingsPage()));
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => GameOrderFormPage(game: item)),
          );
        },
        child: _PlatformCard(item: item),
      ),
    );
  }
}
