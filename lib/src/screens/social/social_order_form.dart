part of '../../app.dart';

class SocialOrderFormPage extends StatefulWidget {
  const SocialOrderFormPage({super.key, required this.platform});

  final ServiceItem platform;

  @override
  State<SocialOrderFormPage> createState() => _SocialOrderFormPageState();
}

class _SocialOrderFormPageState extends State<SocialOrderFormPage> {
  double qty = 0;
  late String category;
  late String selectedService;
  late Future<List<_SocialServicePlan>> _servicesFuture;
  final _linkController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final fallbackCategories = _fallbackCategoriesFor(widget.platform.label);
    category = fallbackCategories.first;
    selectedService = _fallbackServicesFor(widget.platform.label, category).first.label;
    _servicesFuture = _loadServices();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cachedPlans = _cachedServices();
    return FutureBuilder<List<_SocialServicePlan>>(
      future: _servicesFuture,
      initialData: cachedPlans.isNotEmpty ? cachedPlans : null,
      builder: (context, snapshot) {
        final plans = snapshot.data?.isNotEmpty == true
            ? snapshot.data!
            : _fallbackServicesFor(widget.platform.label, category);
        return _buildForm(plans, snapshot.connectionState);
      },
    );
  }

  Widget _buildForm(
    List<_SocialServicePlan> allPlans,
    ConnectionState connectionState,
  ) {
    final categories = _categoriesFrom(allPlans);
    if (!categories.contains(category)) {
      category = categories.first;
    }

    final services = allPlans
        .where((plan) => plan.category == category)
        .toList();
    final visibleServices = services.isEmpty ? allPlans : services;
    if (!visibleServices.any((service) => service.label == selectedService)) {
      selectedService = visibleServices.first.label;
    }
    final servicePlan = visibleServices.firstWhere(
      (service) => service.label == selectedService,
      orElse: () => visibleServices.first,
    );

    return _ReferenceFrame(
      title: widget.platform.label,
      onRefresh: _reloadServices,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      trailing: IconButton(
        onPressed: () {
          _reloadServices();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SocialOrderHeader(platform: widget.platform),
          const SizedBox(height: 16),
          _DropdownShell(
            label: 'Category',
            value: category,
            items: categories,
            onChanged: (value) => setState(() {
              category = value;
              final nextServices = allPlans
                  .where((plan) => plan.category == value)
                  .toList();
              if (nextServices.isNotEmpty) {
                selectedService = nextServices.first.label;
              }
            }),
          ),
          const SizedBox(height: 12),
          _DropdownShell(
            label: 'Service',
            value: selectedService,
            items: visibleServices.map((service) => service.label).toList(),
            onChanged: (value) => setState(() => selectedService = value),
          ),
          if (connectionState == ConnectionState.waiting) ...[
            const SizedBox(height: 8),
            const Text(
              'Loading latest service prices...',
              style: TextStyle(
                color: Color(0xFF7F8898),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ServiceInfoBox(
            averageTime: servicePlan.averageTime.isNotEmpty
                ? servicePlan.averageTime
                : _averageTimeFor(category),
            description: servicePlan.cleanDescription.isNotEmpty
                ? servicePlan.cleanDescription
                : _descriptionFor(widget.platform.label, category),
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Link',
            hint: 'https://profile-link',
            icon: Icons.link_rounded,
            controller: _linkController,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Comment',
            hint: 'Optional note for this order',
            icon: Icons.chat_bubble_outline_rounded,
            controller: _commentController,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Quantity',
            hint: '0',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final nextQty = double.tryParse(value.trim()) ?? 0;
              setState(() => qty = nextQty);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Min: ${servicePlan.min} - Max: ${servicePlan.max}',
            style: TextStyle(
              color: const Color(0xFF687083),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _ApiChargeBox(label: servicePlan.chargeLabel(qty)),
          const SizedBox(height: 22),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : () => _submitOrder(servicePlan),
            child: Text(
              _isSubmitting ? 'Submitting...' : 'Submit Order',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(_SocialServicePlan servicePlan) async {
    final link = _linkController.text.trim();
    final comment = _commentController.text.trim();
    final roundedQty = qty.round();
    if (link.isEmpty) {
      _showMessage('Please enter a link.');
      return;
    }
    if (roundedQty <= 0) {
      _showMessage('Please enter a quantity.');
      return;
    }
    if (servicePlan.min > 0 && roundedQty < servicePlan.min) {
      _showMessage('Minimum quantity is ${servicePlan.min}.');
      return;
    }
    if (servicePlan.max > 0 && roundedQty > servicePlan.max) {
      _showMessage('Maximum quantity is ${servicePlan.max}.');
      return;
    }
    if (!servicePlan.isApiBacked) {
      _showMessage(
        'Latest services are still loading. Please refresh and try again.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await const OrdersApi().create(
      serviceId: servicePlan.id,
      link: link,
      quantity: roundedQty,
      comment: comment,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _linkController.clear();
      _commentController.clear();
      setState(() => qty = 0);
      await _showOrderSuccessDialog(context, result.message);
    } else {
      _showMessage(result.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<List<_SocialServicePlan>> _loadServices() async {
    final result = await const CatalogApi().services(forceRefresh: true);
    final products = result.data ?? const <ApiServiceProduct>[];
    return _plansFromProducts(products);
  }

  Future<void> _reloadServices() async {
    setState(() {
      _servicesFuture = _loadServices();
    });
    await _servicesFuture;
  }

  List<_SocialServicePlan> _cachedServices() {
    final products = CatalogApi.cachedServices ?? const <ApiServiceProduct>[];
    return _plansFromProducts(products);
  }

  List<_SocialServicePlan> _plansFromProducts(
    List<ApiServiceProduct> products,
  ) {
    final plans = products
        .where((product) => _matchesPlatform(product, widget.platform.label))
        .map(_SocialServicePlan.fromApi)
        .toList();
    return plans.isEmpty
        ? _fallbackServicesFor(widget.platform.label, category)
        : plans;
  }

  bool _matchesPlatform(ApiServiceProduct product, String platform) {
    final text = '${product.category} ${product.name}'.toLowerCase();
    final hasApiType =
        product.serviceGroup.trim().isNotEmpty ||
        product.serviceType.trim().isNotEmpty;
    final isTikTokPromote =
        _isTikTokPromoteService(product) ||
        (!hasApiType && _isTikTokPromoteText(text));
    switch (platform) {
      case 'Facebook':
        return _isNormalSmmService(product) &&
            (text.contains('facebook') || text.contains('fb '));
      case 'TikTok Promote':
        return _isTikTokPromoteService(product) ||
            ((text.contains('tiktok') || text.contains('tik tok')) &&
                isTikTokPromote);
      case 'TikTok':
        if (!_isNormalSmmService(product)) return false;
        return (text.contains('tiktok') || text.contains('tik tok')) &&
            !isTikTokPromote;
      case 'Instagram':
        return _isNormalSmmService(product) &&
            (text.contains('instagram') || text.contains(' ig '));
      case 'YouTube':
        return _isNormalSmmService(product) &&
            (text.contains('youtube') || text.contains('you tube'));
      case 'Telegram':
        return _isNormalSmmService(product) && text.contains('telegram');
      case 'Threads':
        return _isNormalSmmService(product) && text.contains('threads');
      case 'Twitter':
        return _isNormalSmmService(product) &&
            (text.contains('twitter') || text.contains('x '));
      default:
        return _isNormalSmmService(product) &&
            text.contains(platform.toLowerCase());
    }
  }

  bool _isTikTokPromoteText(String text) {
    return text.contains('promote') ||
        text.contains('promotion') ||
        text.contains('ads') ||
        text.contains('ad ');
  }

  List<String> _categoriesFrom(List<_SocialServicePlan> plans) {
    final categories = <String>[];
    for (final plan in plans) {
      if (!categories.contains(plan.category)) categories.add(plan.category);
    }
    return categories.isEmpty
        ? _fallbackCategoriesFor(widget.platform.label)
        : categories;
  }

  List<String> _fallbackCategoriesFor(String platform) {
    switch (platform) {
      case 'TikTok':
        return const ['Followers', 'Likes', 'Views'];
      case 'TikTok Promote':
        return const ['Promote Views', 'Promote Likes', 'Promote Followers'];
      case 'YouTube':
        return const ['Subscribers', 'Views', 'Likes'];
      case 'Facebook':
        return const ['Page Likes', 'Followers', 'Post Likes'];
      case 'Telegram':
        return const ['Members', 'Views', 'Reactions'];
      case 'Threads':
      case 'Twitter':
        return const ['Followers', 'Likes', 'Reposts'];
      case 'Instagram':
        return const ['Followers', 'Likes', 'Views'];
      default:
        return const ['Boost', 'Engagement', 'Views'];
    }
  }

  List<_SocialServicePlan> _fallbackServicesFor(String platform, String category) {
    late final List<String> names;

    switch (platform) {
      case 'TikTok':
        names = [
          'TikTok $category [Real]',
          'TikTok $category [HQ]',
          'TikTok $category [Fast]',
        ];
        break;
      case 'TikTok Promote':
        names = [
          'TikTok $category [Campaign]',
          'TikTok $category [Fast Promote]',
          'TikTok $category [Targeted]',
        ];
        break;
      case 'YouTube':
        names = [
          'YouTube $category [HQ]',
          'YouTube $category [Fast]',
          'YouTube $category [Real]',
        ];
        break;
      case 'Facebook':
        names = [
          'Facebook $category [HQ]',
          'Facebook $category [Real]',
          'Facebook $category [Fast]',
        ];
        break;
      case 'Telegram':
        names = [
          'Telegram $category [HQ]',
          'Telegram $category [Fast]',
          'Telegram $category [Real]',
        ];
        break;
      case 'Threads':
        names = [
          'Threads $category [HQ]',
          'Threads $category [Real]',
          'Threads $category [Fast]',
        ];
        break;
      case 'Twitter':
        names = [
          'Twitter $category [HQ]',
          'Twitter $category [Real]',
          'Twitter $category [Fast]',
        ];
        break;
      case 'Instagram':
        names = [
          'Instagram $category [HQ]',
          'Instagram $category [Real]',
          'Instagram $category [Fast]',
        ];
        break;
      default:
        names = [
          'Social $category [Standard]',
          'Social $category [Real]',
          'Social $category [Fast]',
        ];
        break;
    }

    final categoryIndex = _fallbackCategoriesFor(platform).indexOf(category);
    final baseId = _serviceIdBaseFor(platform) + (categoryIndex * 10);
    return List.generate(
      names.length,
      (index) => _SocialServicePlan(
        id: baseId + index + 1,
        category: category,
        name: names[index],
        rate: _rateFor(platform, category),
        min: 100,
        max: 1000000,
        averageTime: _averageTimeFor(category),
        description: _descriptionFor(platform, category),
        priceLabel: _fallbackPriceLabel(_rateFor(platform, category)),
        pricePercent: 100,
        exchangeRate: 0,
        sellingRateUsd: 0,
        sellingRateMmk: 0,
        isUnitPriced: platform == 'TikTok Promote',
        isApiBacked: false,
      ),
    );
  }

  int _serviceIdBaseFor(String platform) {
    switch (platform) {
      case 'Instagram':
        return 1000;
      case 'TikTok':
        return 2000;
      case 'TikTok Promote':
        return 2100;
      case 'YouTube':
        return 3000;
      case 'Facebook':
        return 4000;
      case 'Telegram':
        return 5000;
      case 'Threads':
        return 6000;
      case 'Twitter':
        return 7000;
      default:
        return 9000;
    }
  }

  double _rateFor(String platform, String category) {
    switch (platform) {
      case 'Instagram':
        if (category == 'Followers') return 2.45;
        if (category == 'Likes') return 0.95;
        return 0.35;
      case 'TikTok':
        if (category == 'Followers') return 2.20;
        if (category == 'Likes') return 1.20;
        return 0.45;
      case 'TikTok Promote':
        if (category == 'Promote Followers') return 3.20;
        if (category == 'Promote Likes') return 1.80;
        return 0.95;
      case 'YouTube':
        if (category == 'Subscribers') return 3.50;
        if (category == 'Likes') return 1.10;
        return 0.80;
      case 'Facebook':
        if (category == 'Page Likes') return 2.10;
        if (category == 'Followers') return 1.95;
        return 0.90;
      case 'Telegram':
        if (category == 'Members') return 1.80;
        if (category == 'Reactions') return 0.70;
        return 0.55;
      case 'Threads':
        if (category == 'Followers') return 2.00;
        if (category == 'Reposts') return 1.15;
        return 0.85;
      case 'Twitter':
        if (category == 'Followers') return 2.35;
        if (category == 'Reposts') return 1.25;
        return 0.90;
      default:
        return 1.35;
    }
  }

  String _averageTimeFor(String category) {
    switch (category) {
      case 'Views':
        return '5 - 30 minutes';
      case 'Likes':
      case 'Post Likes':
      case 'Page Likes':
      case 'Reactions':
        return '15 - 60 minutes';
      case 'Followers':
      case 'Subscribers':
      case 'Members':
      case 'Reposts':
        return '1 - 6 hours';
      default:
        return '30 minutes - 3 hours';
    }
  }

  String _descriptionFor(String platform, String category) {
    return '$platform $category service with stable delivery. Use a public profile or post link and avoid changing the link while the order is processing.';
  }
}

class _SocialServicePlan {
  const _SocialServicePlan({
    required this.id,
    required this.category,
    required this.name,
    required this.rate,
    required this.min,
    required this.max,
    required this.averageTime,
    required this.description,
    required this.priceLabel,
    required this.pricePercent,
    required this.exchangeRate,
    required this.sellingRateUsd,
    required this.sellingRateMmk,
    required this.isUnitPriced,
    this.isApiBacked = true,
  });

  final int id;
  final String category;
  final String name;
  final double rate;
  final int min;
  final int max;
  final String averageTime;
  final String description;
  final String priceLabel;
  final double pricePercent;
  final double exchangeRate;
  final double sellingRateUsd;
  final double sellingRateMmk;
  final bool isUnitPriced;
  final bool isApiBacked;

  String get label => '$id  ${_cleanSocialServiceName(name)}';
  String get cleanDescription => _cleanSocialServiceName(description);
  String chargeLabel(double qty) {
    if (qty <= 0) return r'$0.0000 / 0 MMK';
    final units = isUnitPriced ? qty : qty / 1000;
    final mmkRate = _sellingMmkRate;
    final usdRate = _sellingUsdRate;
    final mmkTotal = (mmkRate * units).round();
    return '\$${(usdRate * units).toStringAsFixed(4)} / $mmkTotal MMK';
  }

  double get _sellingUsdRate {
    if (sellingRateUsd > 0) return sellingRateUsd;
    if (exchangeRate > 0) return _sellingMmkRate / exchangeRate;
    if (pricePercent > 0) return rate * pricePercent / 100;
    return rate;
  }

  double get _sellingMmkRate {
    if (sellingRateMmk > 0) return sellingRateMmk;
    if (exchangeRate > 0 && sellingRateUsd > 0) return sellingRateUsd * exchangeRate;
    if (exchangeRate > 0 && pricePercent > 0) {
      return rate * pricePercent / 100 * exchangeRate;
    }
    if (pricePercent > 0) return rate * pricePercent / 100;
    return rate;
  }

  factory _SocialServicePlan.fromApi(ApiServiceProduct product) {
    return _SocialServicePlan(
      id: product.id,
      category: product.category.trim().isEmpty ? 'Other' : product.category,
      name: product.name,
      rate: product.rate,
      min: product.min,
      max: product.max,
      averageTime: product.averageTime,
      description: product.description,
      priceLabel: product.priceLabel.isNotEmpty
          ? product.priceLabel
          : _fallbackPriceLabel(product.rate),
      pricePercent: product.pricePercent,
      exchangeRate: product.exchangeRate,
      sellingRateUsd: product.sellingRateUsd,
      sellingRateMmk: product.sellPriceMmk,
      isUnitPriced: _isTikTokPromoteService(product),
    );
  }
}

String _fallbackPriceLabel(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(4);
}

String _cleanSocialServiceName(String value) {
  return value
      .replaceAll(
        RegExp(
          r'\s*[/|]?\s*(?:အရင်း\s*[/:\-]?\s*)?1\s*\$\s*boost\s*-?\s*5200\s*(?:ks|ကျပ်[^/|၊။,)]*)?',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'\s*/\s*(?=[,။၊)]|$)'), '')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .trim();
}

class _SocialOrderHeader extends StatelessWidget {
  const _SocialOrderHeader({required this.platform});

  final ServiceItem platform;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(platform.label);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(platform.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${platform.services} services available',
                  style: const TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceInfoBox extends StatelessWidget {
  const _ServiceInfoBox({required this.averageTime, required this.description});

  final String averageTime;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _inputShadowDecoration(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D131D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE71F32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFE71F32),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Average Time',
                        style: TextStyle(
                          color: Color(0xFF7F8898),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        averageTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF7F8898),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFFDDE3EF),
                height: 1.35,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
