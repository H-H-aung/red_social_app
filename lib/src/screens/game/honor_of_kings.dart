part of '../../app.dart';

class HonorOfKingsPage extends StatefulWidget {
  const HonorOfKingsPage({super.key});

  @override
  State<HonorOfKingsPage> createState() => _HonorOfKingsPageState();
}

class _HonorOfKingsPageState extends State<HonorOfKingsPage> {
  static const _packages = [
    _HonorTokenPackage(tokens: '16 Tokens', price: 0.99),
    _HonorTokenPackage(tokens: '80 Tokens', price: 4.85),
    _HonorTokenPackage(tokens: '240 Tokens', price: 14.61),
    _HonorTokenPackage(tokens: '400 Tokens', price: 24.36),
    _HonorTokenPackage(tokens: '560 Tokens', price: 34.12),
    _HonorTokenPackage(tokens: '800 +30 Tokens', price: 48.73),
    _HonorTokenPackage(tokens: '1200 +45 Tokens', price: 73.14),
    _HonorTokenPackage(tokens: '2400 +108 Tokens', price: 146.28),
    _HonorTokenPackage(tokens: '4000 +180 Tokens', price: 243.84),
    _HonorTokenPackage(tokens: '8000 +360 Tokens', price: 487.74),
  ];

  final _contactController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPackage = _packages[_selectedIndex];

    return _ReferenceFrame(
      title: 'Honor of Kings',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GameOrderHeader(
            game: ServiceItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Honor of Kings',
              services: '10',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Delivery Contact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Telegram Username / Email',
                    hintStyle: const TextStyle(
                      color: Color(0xFF687083),
                      fontWeight: FontWeight.w700,
                    ),
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      color: Color(0xFFE71F32),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0A111B),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF26344A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE71F32),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Token Package',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 480 ? 3 : 2;
                    const spacing = 10.0;
                    final cardWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 10,
                      children: [
                        for (var index = 0; index < _packages.length; index++)
                          SizedBox(
                            width: cardWidth,
                            child: _HonorTokenCard(
                              package: _packages[index],
                              selected: index == _selectedIndex,
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ServiceInfoBox(
            averageTime: '5 - 30 minutes',
            description:
                'Brazil region Honor of Kings token purchase. The order details will be delivered to your Telegram username or email.',
          ),
          const SizedBox(height: 16),
          _HonorChargeBox(package: selectedPackage),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _submitOrder,
            child: const Text(
              'Submit Order',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _submitOrder() {
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Telegram username or email.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Honor of Kings order is ready.')),
    );
  }
}

class _HonorTokenCard extends StatelessWidget {
  const _HonorTokenCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final _HonorTokenPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF079B73) : const Color(0xFF172231),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF40F0B2)
                  : const Color(0xFF26344A),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0xFF06C991).withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (selected)
                const Positioned(
                  right: -5,
                  top: -5,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFC8F7D0),
                    size: 21,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'R\$ ${package.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.token_rounded,
                        color: Color(0xFF78C8FF),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          package.tokens,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFE9EEF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HonorChargeBox extends StatelessWidget {
  const _HonorChargeBox({required this.package});

  final _HonorTokenPackage package;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Charge',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${package.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                package.tokens,
                style: const TextStyle(
                  color: Color(0xFF7F8898),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HonorTokenPackage {
  const _HonorTokenPackage({required this.tokens, required this.price});

  final String tokens;
  final double price;
}
