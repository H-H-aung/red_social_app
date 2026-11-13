part of '../app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onOpenOrders});

  final VoidCallback? onOpenOrders;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomeApiSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _HomeApiSummary.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeApiSummary>(
      future: _summaryFuture,
      initialData: _HomeApiSummary.fallback,
      builder: (context, snapshot) {
        final summary = snapshot.data ?? _HomeApiSummary.fallback;

        return ValueListenableBuilder<AppUser?>(
          valueListenable: UserSession.current,
          builder: (context, user, _) {
            final account = user ?? AccountPage._guestUser;
            return _HomeFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReferenceHomeTopBar(
                    user: account,
                    onNotification: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReferenceBalanceCard(user: account),
                  const SizedBox(height: 24),
                  const _HomeSectionHeader(title: 'Services'),
                  const SizedBox(height: 12),
                  _ServiceTypeRow(
                    socialSubtitle: summary.socialSubtitle,
                    premiumSubtitle: summary.premiumSubtitle,
                    gameSubtitle: summary.gameSubtitle,
                    onSocial: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SocialPage()),
                    ),
                    onPremium: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumPage()),
                    ),
                    onGame: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GamePage()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _HomeSectionHeader(title: 'Popular Services'),
                  const SizedBox(height: 12),
                  _PopularServicesRow(
                    services: summary.popularServices,
                    onSelected: (service) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SocialOrderFormPage(platform: service),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HomeSectionHeader(
                    title: 'Recent Orders',
                    action: 'View All',
                    onAction: widget.onOpenOrders,
                  ),
                  const SizedBox(height: 12),
                  _RecentOrdersPanel(orders: summary.recentOrders),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeApiSummary {
  const _HomeApiSummary({
    required this.popularServices,
    required this.socialSubtitle,
    required this.premiumSubtitle,
    required this.gameSubtitle,
    required this.recentOrders,
  });

  final List<ServiceItem> popularServices;
  final String socialSubtitle;
  final String premiumSubtitle;
  final String gameSubtitle;
  final List<OrderItem> recentOrders;

  static const fallback = _HomeApiSummary(
    popularServices: _fallbackPopularServices,
    socialSubtitle: 'SMM services',
    premiumSubtitle: 'Paid plans',
    gameSubtitle: 'Items & topup',
    recentOrders: <OrderItem>[],
  );

  static Future<_HomeApiSummary> load() async {
    final catalog = CatalogApi();
    final servicesResult = await catalog.services();
    final gamesResult = await catalog.gameProducts();
    final ordersResult = UserSession.user?.token.isNotEmpty == true
        ? await const OrdersApi().myOrders()
        : const ApiResult<List<OrderItem>>(
            success: false,
            message: 'Login required.',
          );
    final services = servicesResult.data ?? const <ApiServiceProduct>[];
    final games = gamesResult.data ?? const <ApiGameProduct>[];
    final orders = ordersResult.data ?? const <OrderItem>[];
    final popularServices = _buildPopularServices(services);

    return _HomeApiSummary(
      popularServices: popularServices.isEmpty
          ? _fallbackPopularServices
          : popularServices,
      socialSubtitle: _countSubtitle(
        services.length,
        'services',
        'SMM services',
      ),
      premiumSubtitle: _countSubtitle(
        _premiumServiceCount(services),
        'services',
        'Paid plans',
      ),
      gameSubtitle: _countSubtitle(games.length, 'items', 'Items & topup'),
      recentOrders: orders.take(5).toList(),
    );
  }

  static List<ServiceItem> _buildPopularServices(
    List<ApiServiceProduct> services,
  ) {
    const platforms = ['Instagram', 'TikTok', 'YouTube', 'Facebook'];
    return [
      for (final platform in platforms)
        ServiceItem(
          icon: _platformIcon(platform),
          label: platform,
          services: '${_platformServiceCount(services, platform)}+ Services',
        ),
    ].where((item) => !item.services.startsWith('0+')).toList();
  }

  static int _platformServiceCount(
    List<ApiServiceProduct> services,
    String platform,
  ) {
    final value = platform.toLowerCase();
    return services
        .where(
          (service) =>
              _isNormalSmmService(service) &&
              (service.name.toLowerCase().contains(value) ||
                  service.category.toLowerCase().contains(value)),
        )
        .length;
  }

  static int _premiumServiceCount(List<ApiServiceProduct> services) {
    const keywords = [
      'premium',
      'canva',
      'capcut',
      'netflix',
      'telegram',
      'verified',
      'nitro',
      'vip',
    ];
    return services.where((service) {
      if (_isPremiumService(service)) return true;
      if (!_isNormalSmmService(service)) return false;
      final text = '${service.name} ${service.category}'.toLowerCase();
      return keywords.any(text.contains);
    }).length;
  }

  static String _countSubtitle(int count, String label, String fallback) {
    if (count <= 0) return fallback;
    return '$count $label';
  }
}

const _fallbackPopularServices = [
  ServiceItem(
    icon: Icons.camera_alt,
    label: 'Instagram',
    services: '120+ Services',
  ),
  ServiceItem(
    icon: Icons.music_note,
    label: 'TikTok',
    services: '90+ Services',
  ),
  ServiceItem(
    icon: Icons.play_arrow_rounded,
    label: 'YouTube',
    services: '80+ Services',
  ),
  ServiceItem(
    icon: Icons.facebook,
    label: 'Facebook',
    services: '70+ Services',
  ),
];

IconData _platformIcon(String label) {
  final value = label.toLowerCase();
  if (value.contains('facebook')) return Icons.facebook;
  if (value.contains('tiktok')) return Icons.music_note;
  if (value.contains('youtube')) return Icons.play_arrow_rounded;
  if (value.contains('telegram')) return Icons.send_rounded;
  if (value.contains('threads')) return Icons.alternate_email_rounded;
  if (value.contains('twitter')) return Icons.close_rounded;
  if (value.contains('premium')) return Icons.workspace_premium_rounded;
  if (value.contains('game')) return Icons.sports_esports_rounded;
  return Icons.camera_alt;
}
