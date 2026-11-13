part of '../../app.dart';

class FreeFirePage extends StatefulWidget {
  const FreeFirePage({super.key});

  @override
  State<FreeFirePage> createState() => _FreeFirePageState();
}

class _FreeFirePageState extends State<FreeFirePage> {
  static const _packages = [
    _FreeFirePackage(diamonds: '100', bonus: '+10% Bonus', price: 4.49),
    _FreeFirePackage(diamonds: '310', bonus: '+10% Bonus', price: 13.99),
    _FreeFirePackage(diamonds: '520', bonus: '+10% Bonus', price: 20.99),
    _FreeFirePackage(diamonds: '1060', bonus: '+10% Bonus', price: 44.99),
    _FreeFirePackage(diamonds: '2180', bonus: '+10% Bonus', price: 87.99),
    _FreeFirePackage(diamonds: '5600', bonus: '+10% Bonus', price: 209.99),
  ];

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _playerIdController = TextEditingController();
  int _selectedIndex = 2;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _playerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPackage = _packages[_selectedIndex];

    return _ReferenceFrame(
      title: 'Free Fire',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GameOrderHeader(
            game: ServiceItem(
              icon: Icons.local_fire_department_rounded,
              label: 'Free Fire',
              services: '6',
            ),
          ),
          const SizedBox(height: 16),
          _FreeFireSection(
            number: '1',
            title: 'Enter Account Information',
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final fieldWidth = (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: _FreeFireTextField(
                        controller: _nameController,
                        hint: 'Name',
                        icon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _FreeFireTextField(
                        controller: _birthDateController,
                        hint: 'Date of Birth (DD-MM-YYYY)',
                        icon: Icons.calendar_month_outlined,
                        readOnly: true,
                        onTap: _selectBirthDate,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _FreeFireTextField(
                        controller: _cpfController,
                        hint: 'CPF',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _FreeFireTextField(
                        controller: _playerIdController,
                        hint: 'Player ID',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _FreeFireSection(
            number: '2',
            title: 'Select Top Up',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 480 ? 3 : 2;
                const spacing = 10.0;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  children: [
                    for (var index = 0; index < _packages.length; index++)
                      SizedBox(
                        width: itemWidth,
                        child: _FreeFirePackageCard(
                          package: _packages[index],
                          selected: index == _selectedIndex,
                          onTap: () => setState(() => _selectedIndex = index),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const _ServiceInfoBox(
            averageTime: '5 - 30 minutes',
            description:
                'Brazil region Free Fire diamond top up. Please enter the correct Player ID before submitting your order.',
          ),
          const SizedBox(height: 16),
          _ChargeBox(total: selectedPackage.price),
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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (selectedDate == null) return;

    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    _birthDateController.text = '$day-$month-${selectedDate.year}';
  }

  void _submitOrder() {
    final fields = {
      'Name': _nameController.text,
      'Date of Birth': _birthDateController.text,
      'CPF': _cpfController.text,
      'Player ID': _playerIdController.text,
    };

    for (final entry in fields.entries) {
      if (entry.value.trim().isNotEmpty) continue;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter ${entry.key}.')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Free Fire order is ready to submit.')),
    );
  }
}

class _FreeFireTextField extends StatelessWidget {
  const _FreeFireTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF687083),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFE71F32), size: 20),
        filled: true,
        fillColor: const Color(0xFF0A111B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF26344A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE71F32), width: 1.4),
        ),
      ),
    );
  }
}

class _FreeFireSection extends StatelessWidget {
  const _FreeFireSection({
    required this.number,
    required this.title,
    required this.child,
  });

  final String number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE71F32),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FreeFirePackageCard extends StatelessWidget {
  const _FreeFirePackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final _FreeFirePackage package;
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
          height: 118,
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
                        Icons.diamond_rounded,
                        color: Color(0xFF68D8FF),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${package.diamonds} Diamonds',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.bonus,
                    style: const TextStyle(
                      color: Color(0xFF42F0B0),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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
}

class _FreeFirePackage {
  const _FreeFirePackage({
    required this.diamonds,
    required this.bonus,
    required this.price,
  });

  final String diamonds;
  final String bonus;
  final double price;
}
