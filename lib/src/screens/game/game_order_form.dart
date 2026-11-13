part of '../../app.dart';

class GameOrderFormPage extends StatefulWidget {
  const GameOrderFormPage({super.key, required this.game});

  final ServiceItem game;

  @override
  State<GameOrderFormPage> createState() => _GameOrderFormPageState();
}

class _GameOrderFormPageState extends State<GameOrderFormPage> {
  double qty = 1;
  late String category;
  late String package;
  late Future<List<_GameProductPlan>> _productsFuture;
  final _playerIdController = TextEditingController();
  final _zoneIdController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    category = _categoriesFor(widget.game.label).first;
    package = _packagesFor(widget.game.label, category).first;
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _playerIdController.dispose();
    _zoneIdController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cachedProducts = _cachedProducts();
    return FutureBuilder<List<_GameProductPlan>>(
      future: _productsFuture,
      initialData: cachedProducts.isNotEmpty ? cachedProducts : null,
      builder: (context, snapshot) {
        final products = snapshot.data?.isNotEmpty == true
            ? snapshot.data!
            : const <_GameProductPlan>[];
        return _buildForm(products, snapshot.connectionState);
      },
    );
  }

  Widget _buildForm(
    List<_GameProductPlan> allProducts,
    ConnectionState connectionState,
  ) {
    final isVoucherCode = widget.game.label == 'PUBG Voucher Code';
    final showsCategory = !isVoucherCode;
    if (allProducts.isEmpty) {
        return _ReferenceFrame(
          title: widget.game.label,
          onRefresh: _reloadProducts,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFFE9EEF8),
          ),
        ),
        trailing: IconButton(
          onPressed: () {
            _reloadProducts();
          },
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GameOrderHeader(game: widget.game),
            const SizedBox(height: 16),
            _GameProductsMessage(
              isLoading: connectionState == ConnectionState.waiting,
            ),
          ],
        ),
      );
    }

    final categories = _categoriesFrom(allProducts);
    if (!categories.contains(category)) {
      category = categories.first;
    }
    final products = allProducts
        .where((product) => product.category == category)
        .toList();
    final visibleProducts = products.isEmpty ? allProducts : products;
    if (!visibleProducts.any((product) => product.label == package)) {
      package = visibleProducts.first.label;
    }
    final selectedProduct = visibleProducts.firstWhere(
      (product) => product.label == package,
      orElse: () => visibleProducts.first,
    );
    final total = qty * selectedProduct.price;

    return _ReferenceFrame(
      title: widget.game.label,
      onRefresh: _reloadProducts,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      trailing: IconButton(
        onPressed: () {
          _reloadProducts();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GameOrderHeader(game: widget.game),
          const SizedBox(height: 16),
          if (!isVoucherCode) ...[
            _GameUserIdFields(
              playerController: _playerIdController,
              zoneController: _zoneIdController,
              showZoneId: widget.game.label != 'PUBG UC',
            ),
            const SizedBox(height: 12),
          ],
          if (showsCategory) ...[
            _DropdownShell(
              label: 'Category',
              value: category,
              items: categories,
              onChanged: (value) => setState(() {
                category = value;
                final nextProducts = allProducts
                    .where((product) => product.category == value)
                    .toList();
                if (nextProducts.isNotEmpty) {
                  package = nextProducts.first.label;
                }
              }),
            ),
            const SizedBox(height: 12),
          ],
          _GameProductList(
            products: visibleProducts,
            selected: package,
            onChanged: (value) => setState(() => package = value),
          ),
          if (connectionState == ConnectionState.waiting) ...[
            const SizedBox(height: 8),
            const Text(
              'Loading latest game items...',
              style: TextStyle(
                color: Color(0xFF7F8898),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ServiceInfoBox(
            averageTime: selectedProduct.averageTime.isNotEmpty
                ? selectedProduct.averageTime
                : _averageTimeFor(widget.game.label),
            description: selectedProduct.description.isNotEmpty
                ? selectedProduct.description
                : _descriptionFor(widget.game.label, category),
          ),
          if (isVoucherCode) ...[
            const SizedBox(height: 12),
            _VoucherContactField(controller: _contactController),
          ],

          const SizedBox(height: 18),
          _ChargeBox(total: total),
          const SizedBox(height: 22),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting
                ? null
                : () => _submitOrder(selectedProduct, isVoucherCode),
            child: Text(
              _isSubmitting ? 'Submitting...' : 'Submit Order',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _productsFuture = _loadProducts();
    });
    await _productsFuture;
  }

  Future<void> _submitOrder(
    _GameProductPlan selectedProduct,
    bool isVoucherCode,
  ) async {
    final user = UserSession.user;
    if (user?.token.isNotEmpty != true || user!.id <= 0) {
      _showMessage('Please login to submit game order.');
      return;
    }
    final playerId = _playerIdController.text.trim();
    final zoneId = _zoneIdController.text.trim();
    final contact = _contactController.text.trim();
    if (isVoucherCode) {
      if (contact.isEmpty) {
        _showMessage('Please enter Telegram username or email.');
        return;
      }
    } else {
      if (playerId.isEmpty) {
        _showMessage('Please enter Player ID.');
        return;
      }
      if (widget.game.label != 'PUBG UC' && zoneId.isEmpty) {
        _showMessage('Please enter Zone ID.');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    final result = await const OrdersApi().createGame(
      userId: user.id,
      productId: selectedProduct.id,
      quantity: qty.round(),
      playerId: playerId,
      zoneId: zoneId,
      contact: contact,
      note: '${widget.game.label} - ${selectedProduct.name}',
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _playerIdController.clear();
      _zoneIdController.clear();
      _contactController.clear();
      await _showOrderSuccessDialog(
        context,
        _gameOrderMessage(result.message),
      );
    } else {
      _showMessage(_gameOrderMessage(result.message));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _gameOrderMessage(String message) {
    if (message.toLowerCase().contains('product selling price is not set')) {
      return 'This game product price is not ready yet. Please choose another product.';
    }
    return message;
  }

  Future<List<_GameProductPlan>> _loadProducts() async {
    final result = await const CatalogApi().gameProducts(forceRefresh: true);
    final products = result.data ?? const <ApiGameProduct>[];
    return _plansFromProducts(products);
  }

  List<_GameProductPlan> _cachedProducts() {
    final products = CatalogApi.cachedGameProducts ?? const <ApiGameProduct>[];
    return _plansFromProducts(products);
  }

  List<_GameProductPlan> _plansFromProducts(List<ApiGameProduct> products) {
    final plans = products
        .where((product) => _matchesGame(product, widget.game.label))
        .where((product) => product.sellPriceMmk > 0)
        .map(_GameProductPlan.fromApi)
        .toList()
      ..sort((a, b) {
        final categoryOrder = a.category.compareTo(b.category);
        if (categoryOrder != 0) return categoryOrder;
        return a.id.compareTo(b.id);
      });
    return plans;
  }

  bool _matchesGame(ApiGameProduct product, String game) {
    final key = product.gameKey.toLowerCase();
    final name = product.gameName.toLowerCase();
    switch (game) {
      case 'Mobile Legends':
      case 'MLBB':
      case 'Smile One BR':
        return key == 'mobile_legends' || name.contains('mobile legends');
      case 'Magic Chess: Go Go':
        return key == 'magic_chess' || name.contains('magic chess');
      case 'PUBG UC':
        return key == 'pubg_uc' || name == 'pubg uc';
      case 'PUBG Voucher Code':
        return key == 'pubg_voucher' || name.contains('voucher');
      case 'Free Fire':
        return key == 'free_fire' || name.contains('free fire');
      case 'Honor of Kings':
        return key == 'honor_of_kings' || name.contains('honor of kings');
      default:
        return name.contains(game.toLowerCase());
    }
  }

  List<String> _categoriesFrom(List<_GameProductPlan> products) {
    final categories = <String>[];
    for (final product in products) {
      if (!categories.contains(product.category)) categories.add(product.category);
    }
    return categories.isEmpty ? _categoriesFor(widget.game.label) : categories;
  }

  List<String> _categoriesFor(String game) {
    switch (game) {
      case 'Mobile Legends':
      case 'Smile One BR':
        return const [
          'Small Diamonds',
          'Diamonds',
          'Elite Weekly Package',
          'Epic Monthly Package',
          'Weekly Pass',
          'Twilight passage',
        ];
      case 'Free Fire':
        return const ['Diamonds', 'Weekly Membership', 'Monthly Membership'];
      case 'Magic Chess: Go Go':
        return const ['Diamonds', 'Weekly Pass', 'Monthly Pass'];
      case 'MLBB':
        return const ['Diamonds', 'Weekly Pass', 'Twilight Pass'];
      case 'PUBG UC':
        return const [
          'UC Package',
          'ELITE PASS (LV1-100)',
          'ELITE PASS PLUS (LV1-100)',
          'First Purchase Pack',
          'Upgradable Firearm Materials Pack',
          'Mythic Emblem Pack',
        ];
      case 'PUBG Voucher Code':
        return const ['Voucher Code', 'Weekly Code', 'Monthly Code'];
      case 'Diamonds':
        return const ['Small Pack', 'Medium Pack', 'Large Pack'];
      case 'Gift Cards':
        return const ['Google Play', 'Steam', 'Razer Gold'];
      default:
        return const ['Top Up', 'Item Pack', 'Gift'];
    }
  }

  List<String> _packagesFor(String game, String category) {
    switch (game) {
      case 'Mobile Legends':
      case 'Smile One BR':
        return _mobileLegendsBrazilPackages(category);
      case 'Free Fire':
        return _freeFireBrazilPackages(category);
      case 'Magic Chess: Go Go':
        return _magicChessPackages(category);
      case 'MLBB':
        return [
          'MLBB $category - Basic',
          'MLBB $category - Value',
          'MLBB $category - Premium',
        ];
      case 'PUBG UC':
        return _pubgUcPackages(category);
      case 'PUBG Voucher Code':
        return _pubgVoucherPackages(category);
      case 'Gift Cards':
        return ['$category \$5', '$category \$10', '$category \$20'];
      default:
        return [
          '$game $category - Basic',
          '$game $category - Value',
          '$game $category - Premium',
        ];
    }
  }

  String _averageTimeFor(String game) {
    switch (game) {
      case 'Mobile Legends':
      case 'Smile One BR':
      case 'Free Fire':
      case 'PUBG UC':
      case 'PUBG Voucher Code':
      case 'MLBB':
        return '5 - 30 minutes';
      case 'Gift Cards':
        return '5 - 20 minutes';
      default:
        return '10 - 45 minutes';
    }
  }

  String _descriptionFor(String game, String category) {
    if (game == 'Mobile Legends' ||
        game == 'Smile One BR' ||
        game == 'Free Fire' ||
        game == 'Magic Chess: Go Go') {
      return 'Brazil region $category top up. Please enter Player ID and Zone ID correctly before submitting.';
    }

    if (game == 'PUBG Voucher Code') {
      return 'PUBG voucher code delivery. Please check your contact detail and redeem the code in the correct region.';
    }

    return '\$game $category order with fast delivery. Please check Player ID and Server / Zone carefully before submitting.';
  }

  List<String> _pubgUcPackages(String category) {
    switch (category) {
      case 'UC Package':
        return const [
          'PUBG UC 60',
          'PUBG UC 300 +25',
          'PUBG UC 600 +60',
          'PUBG UC 1500 +300',
          'PUBG UC 3000 +850',
          'PUBG UC 6000 +2100',
          'PUBG UC 12000 +4200',
          'PUBG UC 18000 +6300',
          'PUBG UC 24000 +8400',
          'PUBG UC 30000 +10500',
          'PUBG UC 36000 +12600',
          'PUBG UC 60000 +21000',
        ];
      case 'ELITE PASS (LV1-100)':
        return const ['ELITE PASS (LV1-100)'];
      case 'ELITE PASS PLUS (LV1-100)':
        return const ['ELITE PASS PLUS (LV1-100)'];
      case 'First Purchase Pack':
        return const ['First Purchase Pack'];
      case 'Upgradable Firearm Materials Pack':
        return const ['Upgradable Firearm Materials Pack'];
      case 'Mythic Emblem Pack':
        return const ['Mythic Emblem Pack'];
      default:
        return const ['ELITE PASS (LV1-100)'];
    }
  }

  List<String> _pubgVoucherPackages(String category) {
    switch (category) {
      case 'Weekly Code':
        return const ['PUBG Weekly Voucher Code'];
      case 'Monthly Code':
        return const ['PUBG Monthly Voucher Code'];
      default:
        return const [
          'PUBG Voucher Code - 60 UC',
          'PUBG Voucher Code - 325 UC',
          'PUBG Voucher Code - 660 UC',
          'PUBG Voucher Code - 1800 UC',
          'PUBG Voucher Code - 3850 UC',
          'PUBG Voucher Code - 8100 UC',
        ];
    }
  }

  List<String> _mobileLegendsBrazilPackages(String category) {
    switch (category) {
      case 'Elite Weekly Package':
        return const ['Elite Weekly Package - Available Once a Week'];
      case 'Epic Monthly Package':
        return const ['Epic Monthly Package - Available Once a Month'];
      case 'Weekly Pass':
        return const ['Weekly Diamond Pass'];
      case 'Twilight passage':
        return const ['Twilight passage'];
      case 'Small Diamonds':
        return const [
          'Diamond x50 +50',
          'Diamond x150 +150',
          'Diamond x250 +250',
          'Diamond x500 +500',
        ];
      default:
        return const [
          'Diamond x78 +8',
          'Diamond x156 +16',
          'Diamond x234 +23',
          'Diamond x625 +81',
          'Diamond x1860 +335',
          'Diamond x3099 +589',
          'Diamond x4649 +883',
          'Diamond x7740 +1548',
        ];
    }
  }

  List<String> _magicChessPackages(String category) {
    switch (category) {
      case 'Weekly Pass':
        return const ['Magic Chess: Go Go - Weekly Pass'];
      case 'Monthly Pass':
        return const ['Magic Chess: Go Go - Monthly Pass'];
      default:
        return const [
          'Magic Chess: Go Go - Diamond x50 +50',
          'Magic Chess: Go Go - Diamond x150 +150',
          'Magic Chess: Go Go - Diamond x250 +250',
          'Magic Chess: Go Go - Diamond x500 +500',
        ];
    }
  }

  List<String> _freeFireBrazilPackages(String category) {
    switch (category) {
      case 'Weekly Membership':
        return const ['Free Fire - Weekly Membership'];
      case 'Monthly Membership':
        return const ['Free Fire - Monthly Membership'];
      default:
        return const [
          'Free Fire - 100 Diamonds',
          'Free Fire - 310 Diamonds',
          'Free Fire - 520 Diamonds',
          'Free Fire - 1060 Diamonds',
        ];
    }
  }

}

class _GameUserIdFields extends StatelessWidget {
  const _GameUserIdFields({
    required this.playerController,
    required this.zoneController,
    this.showZoneId = true,
  });

  final TextEditingController playerController;
  final TextEditingController zoneController;
  final bool showZoneId;

  @override
  Widget build(BuildContext context) {
    final playerField = _TextFieldShell(
      label: 'Player ID',
      hint: 'Enter player ID',
      icon: Icons.badge_outlined,
      controller: playerController,
    );

    if (!showZoneId) return playerField;

    return Row(
      children: [
        Expanded(
          child: _TextFieldShell(
            label: 'Player ID',
            hint: 'Enter player ID',
            icon: Icons.badge_outlined,
            controller: playerController,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TextFieldShell(
            label: 'Zone ID',
            hint: 'Example: 1234',
            icon: Icons.dns_outlined,
            controller: zoneController,
          ),
        ),
      ],
    );
  }
}

class _GameProductsMessage extends StatelessWidget {
  const _GameProductsMessage({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Color(0xFFE71F32),
              ),
            )
          else
            const Icon(
              Icons.price_check_rounded,
              color: Color(0xFF7F8898),
              size: 34,
            ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Loading game products...' : 'No priced products',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isLoading
                ? 'Please wait while latest prices are loaded.'
                : 'Admin needs to set selling price for this game before users can order.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7F8898),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherContactField extends StatelessWidget {
  const _VoucherContactField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _TextFieldShell(
      label: 'Telegram Username / Email',
      hint: '@username or email@example.com',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      controller: controller,
    );
  }
}

class _GameProductPlan {
  const _GameProductPlan({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    this.averageTime = '',
    this.description = '',
  });

  final int id;
  final String category;
  final String name;
  final double price;
  final String averageTime;
  final String description;

  String get label => '$id  $name';

  String get displayPrice => '\$${price.toStringAsFixed(2)}';

  factory _GameProductPlan.fromApi(ApiGameProduct product) {
    return _GameProductPlan(
      id: product.id,
      category: product.category.trim().isEmpty ? 'Package' : product.category,
      name: product.productName,
      price: product.sellPriceMmk / kUsdToMmkRate,
      averageTime: product.averageTime,
      description: product.description,
    );
  }
}

class _GameProductList extends StatelessWidget {
  const _GameProductList({
    required this.products,
    required this.selected,
    required this.onChanged,
  });

  final List<_GameProductPlan> products;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Product',
            style: TextStyle(
              color: Color(0xFFB8C0CE),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 430;
            final columns = isWide ? 3 : 2;
            final spacing = 10.0;
            final width =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: 10,
              children: [
                for (final product in products)
                  SizedBox(
                    width: width,
                    child: _GameProductTile(
                      product: product,
                      active: product.label == selected,
                      onTap: () => onChanged(product.label),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GameProductTile extends StatelessWidget {
  const _GameProductTile({
    required this.product,
    required this.active,
    required this.onTap,
  });

  final _GameProductPlan product;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = product.displayPrice;
    final icon = _productIcon(product.name);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 86,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF079B73) : const Color(0xFF172231),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? const Color(0xFF40F0B2) : const Color(0xFF223047),
              width: active ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? const Color(0xFF06C991).withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.30),
                blurRadius: active ? 16 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (active)
                const Positioned(
                  right: -8,
                  top: -8,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFC8F7D0),
                    size: 22,
                  ),
                ),
              Positioned(
                right: 2,
                top: 2,
                child: Icon(
                  icon,
                  color: active ? Colors.white : const Color(0xFF67D7FF),
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE9EEF8),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFFDDE3EF),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _productIcon(String product) {
    if (product.contains('Voucher Code')) {
      return Icons.confirmation_number_rounded;
    }
    if (product.contains('Package')) return Icons.workspace_premium_rounded;
    if (product.contains('Pass') || product.contains('passage')) {
      return Icons.card_membership_rounded;
    }
    if (product.contains('500') ||
        product.contains('625') ||
        product.contains('1860') ||
        product.contains('3099') ||
        product.contains('4649') ||
        product.contains('7740')) {
      return Icons.inventory_2_rounded;
    }
    return Icons.diamond_rounded;
  }
}

class _GameOrderHeader extends StatelessWidget {
  const _GameOrderHeader({required this.game});

  final ServiceItem game;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(game.label);
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
            child: Icon(game.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${game.services} game items available',
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
