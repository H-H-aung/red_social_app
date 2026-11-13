part of '../../app.dart';

class PremiumOrderFormPage extends StatefulWidget {
  const PremiumOrderFormPage({super.key, required this.service});

  final ServiceItem service;

  @override
  State<PremiumOrderFormPage> createState() => _PremiumOrderFormPageState();
}

class _PremiumOrderFormPageState extends State<PremiumOrderFormPage> {
  double qty = 1;
  late String selectedService;
  late Future<List<_PremiumServicePlan>> _plansFuture;
  final _contactController = TextEditingController();
  bool _isSubmitting = false;

  static const services = [
    _PremiumServicePlan(
      group: 'Canva',
      id: '197',
      name: 'Canva Edu Lifetime - 1 Year Warranty | 1500 Ks',
      price: 0.7143,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Capcut',
      id: '513',
      name: 'Capcut Pro 1',
      price: 21.0000,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Meitu VIP / SVIP',
      id: '1253',
      name: 'Meitu VIP - 1 Month (20,000 ks)',
      price: 9.5238,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Meitu VIP / SVIP',
      id: '1254',
      name: 'Meitu VIP - 1 Year | Special VIP (100,000 ks)',
      price: 47.6190,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Meitu VIP / SVIP',
      id: '1255',
      name: 'Meitu SVIP - 1 Month | Special VIP (33,000 ks)',
      price: 15.7142,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Meitu VIP / SVIP',
      id: '1256',
      name: 'Meitu SVIP - 3 Month | Special VIP (95,000 ks)',
      price: 45.2381,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Meitu VIP / SVIP',
      id: '1257',
      name: 'Meitu SVIP - 1 Year | Special VIP (210,000 ks)',
      price: 100.0000,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Telegram Premium',
      id: '391',
      name: 'Telegram Premium Membership Official Gift Plan | 3 Months | 58000 ks',
      price: 27.6190,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Telegram Premium',
      id: '392',
      name: 'Telegram Premium Membership Official Gift Plan | 6 Months | 79500 ks',
      price: 37.8571,
      pricePercent: 110,
    ),
    _PremiumServicePlan(
      group: 'Telegram Premium',
      id: '393',
      name: 'Telegram Premium Membership Official Gift Plan | 1 Year | 140000 ks',
      price: 66.6666,
      pricePercent: 110,
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedService = _plansFor(widget.service.label).first.label;
    _plansFuture = _loadPlans(widget.service.label);
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_PremiumServicePlan>>(
      future: _plansFuture,
      initialData: _plansFor(widget.service.label),
      builder: (context, snapshot) {
        final plans = snapshot.data?.isNotEmpty == true
            ? snapshot.data!
            : _plansFor(widget.service.label);
        return _buildForm(plans);
      },
    );
  }

  Widget _buildForm(List<_PremiumServicePlan> plans) {
    if (!plans.any((service) => service.label == selectedService)) {
      selectedService = plans.first.label;
    }
    final servicePlan = plans.firstWhere(
      (service) => service.label == selectedService,
      orElse: () => plans.first,
    );

    return _ReferenceFrame(
      title: widget.service.label,
      onRefresh: _reloadPlans,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      trailing: IconButton(
        onPressed: () {
          _reloadPlans();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PremiumOrderHeader(service: widget.service),
          const SizedBox(height: 16),
          _DropdownShell(
            label: 'Service',
            value: selectedService,
            items: plans.map((plan) => plan.label).toList(),
            onChanged: (value) => setState(() => selectedService = value),
          ),
          const SizedBox(height: 12),
          _PremiumServiceInfo(plan: servicePlan),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Telegram Username / Email',
            hint: '@username or email@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            controller: _contactController,
          ),
          const SizedBox(height: 12),
          _ServiceInfoBox(
            averageTime: _averageTimeFor(servicePlan),
            description: _descriptionFor(servicePlan),
          ),
          const SizedBox(height: 18),
          _ApiChargeBox(label: servicePlan.effectivePriceLabel),
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

  Future<void> _submitOrder(_PremiumServicePlan servicePlan) async {
    if (UserSession.user?.token.isNotEmpty != true) {
      _showMessage('Please login to submit premium order.');
      return;
    }

    final contact = _contactController.text.trim();
    final isTelegram = RegExp(r'^@[A-Za-z0-9_]{5,32}$').hasMatch(contact);
    final isEmail = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    ).hasMatch(contact);

    if (!isTelegram && !isEmail) {
      _showMessage('Please enter a valid Telegram username or email address.');
      return;
    }

    final serviceId = int.tryParse(servicePlan.id);
    if (serviceId == null || serviceId <= 0) {
      _showMessage('This premium service is not ready to order.');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await const OrdersApi().create(
      serviceId: serviceId,
      link: contact,
      quantity: qty.round(),
      comment: '${widget.service.label} - ${servicePlan.cleanName}',
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _contactController.clear();
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

  List<_PremiumServicePlan> _plansFor(String group) {
    final plans = services.where((service) => service.group == group).toList();
    return plans.isEmpty ? services : plans;
  }

  Future<List<_PremiumServicePlan>> _loadPlans(String group) async {
    final result = await const CatalogApi().services();
    final products = result.data ?? const <ApiServiceProduct>[];
    final plans =
        products
            .where(_isPremiumService)
            .map((product) => _PremiumServicePlan.fromApi(product))
            .where((plan) => _matchesGroup(plan, group))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return plans.isEmpty ? _plansFor(group) : plans;
  }

  Future<void> _reloadPlans() async {
    setState(() {
      _plansFuture = _loadPlans(widget.service.label);
    });
    await _plansFuture;
  }

  bool _matchesGroup(_PremiumServicePlan plan, String group) {
    return _normalizePremiumGroup(group) == plan.group;
  }

  String _averageTimeFor(_PremiumServicePlan plan) {
    if (plan.averageTime.trim().isNotEmpty) return plan.averageTime;
    switch (plan.group) {
      case 'Canva':
      case 'Capcut':
        return '5 - 30 minutes';
      case 'Telegram Premium':
      case 'Netflix':
        return '10 - 60 minutes';
      default:
        return '5 - 45 minutes';
    }
  }

  String _descriptionFor(_PremiumServicePlan plan) {
    if (plan.description.trim().isNotEmpty) return plan.description;
    if (plan.group == 'Telegram Premium') {
      return 'Telegram Premium gift plan. Please provide a valid Telegram username or account link.';
    }
    if (plan.group == 'Netflix') {
      return 'Netflix account service. Please provide your email, Telegram username, or account link for delivery contact.';
    }
    return '${plan.cleanName} premium service. Please enter the correct email, Telegram username, or account link before submitting.';
  }
}

class _PremiumServicePlan {
  const _PremiumServicePlan({
    required this.group,
    required this.id,
    required this.name,
    required this.price,
    this.priceLabel = '',
    this.pricePercent = 100,
    this.exchangeRate = 0,
    this.sellingRateUsd = 0,
    this.sellingRateMmk = 0,
    this.averageTime = '',
    this.description = '',
  });

  final String group;
  final String id;
  final String name;
  final double price;
  final String priceLabel;
  final double pricePercent;
  final double exchangeRate;
  final double sellingRateUsd;
  final double sellingRateMmk;
  final String averageTime;
  final String description;

  String get cleanName => _cleanPremiumServiceName(name);
  String get label => '$id  $cleanName';
  String get effectivePriceLabel {
    final apiLabel = priceLabel.trim();
    if (apiLabel.startsWith(r'$') || apiLabel.toUpperCase().contains('MMK')) {
      return apiLabel;
    }
    if (sellingRateUsd > 0 && sellingRateMmk > 0) {
      return '\$${sellingRateUsd.toStringAsFixed(4)} / ${sellingRateMmk.round()} MMK';
    }
    final mmkRate = _sellingMmkRate;
    return '\$${_sellingUsdRate.toStringAsFixed(4)} / ${mmkRate.round()} MMK';
  }

  double get _sellingUsdRate {
    if (sellingRateUsd > 0) return sellingRateUsd;
    if (exchangeRate > 0) return _sellingMmkRate / exchangeRate;
    if (pricePercent > 0) return price * pricePercent / 100;
    return price;
  }

  double get _sellingMmkRate {
    if (sellingRateMmk > 0) return sellingRateMmk;
    if (exchangeRate > 0 && sellingRateUsd > 0) {
      return sellingRateUsd * exchangeRate;
    }
    if (exchangeRate > 0 && pricePercent > 0) {
      return price * pricePercent / 100 * exchangeRate;
    }
    if (pricePercent > 0) {
      return price * pricePercent / 100 * kPremiumUsdToMmkRate;
    }
    if (price > 0) return price * kPremiumUsdToMmkRate;
    return price;
  }

  factory _PremiumServicePlan.fromApi(ApiServiceProduct product) {
    return _PremiumServicePlan(
      group: _premiumGroupFor(product),
      id: product.id.toString(),
      name: product.name,
      price: product.rate,
      priceLabel: product.priceLabel.isNotEmpty
          ? product.priceLabel
          : _fallbackPriceLabel(product.rate),
      pricePercent: product.pricePercent,
      exchangeRate: product.exchangeRate,
      sellingRateUsd: product.sellingRateUsd,
      sellingRateMmk: product.sellingRateMmk > 0
          ? product.sellingRateMmk
          : product.sellPriceMmk,
      averageTime: product.averageTime,
      description: product.description,
    );
  }
}

String _premiumGroupFor(ApiServiceProduct product) {
  final text = '${product.name} ${product.category}'.toLowerCase();
  if (text.contains('meitu')) return 'Meitu VIP / SVIP';
  if (text.contains('telegram')) return 'Telegram Premium';
  if (text.contains('netflix')) return 'Netflix';
  if (text.contains('capcut') || text.contains('cap cut')) return 'Capcut';
  if (text.contains('canva')) return 'Canva';
  return _normalizePremiumGroup(product.category);
}

String _normalizePremiumGroup(String value) {
  final text = value.toLowerCase();
  if (text.contains('meitu')) return 'Meitu VIP / SVIP';
  if (text.contains('telegram')) return 'Telegram Premium';
  if (text.contains('netflix')) return 'Netflix';
  if (text.contains('capcut') || text.contains('cap cut')) return 'Capcut';
  if (text.contains('canva')) return 'Canva';
  return value.trim();
}

String _cleanPremiumServiceName(String value) {
  return value
      .replaceAll(
        RegExp(
          r'\s*\((?:[\d,.]+\s*(?:ks|mmk|kyat|kyats|usd)|\$\s*[\d,.]+)\)',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(
          r'\s*\|\s*(?:[\d,.]+\s*(?:ks|mmk|kyat|kyats|usd)|\$\s*[\d,.]+)\s*$',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(
          r'\s*[-|]\s*(?:[\d,.]+\s*(?:ks|mmk|kyat|kyats|usd)|\$\s*[\d,.]+)\s*$',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .replaceAll(RegExp(r'\s+\|$'), '')
      .trim();
}

class _PremiumServiceInfo extends StatelessWidget {
  const _PremiumServiceInfo({required this.plan});

  final _PremiumServicePlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0D6EFD),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              plan.id,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plan.cleanName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE9EEF8),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.effectivePriceLabel,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumOrderHeader extends StatelessWidget {
  const _PremiumOrderHeader({required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(service.label);
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
            child: Icon(service.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.services} premium plans available',
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
