part of '../app.dart';

class _ChargeBox extends StatelessWidget {
  const _ChargeBox({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final mmkTotal = _usdToMmk(total);

    return Container(
      decoration: _inputShadowDecoration(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D131D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Charge',
              style: TextStyle(
                color: Color(0xFFE9EEF8),
                fontWeight: FontWeight.w800,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mmkTotal.toString()} MMK',
                  style: const TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiChargeBox extends StatelessWidget {
  const _ApiChargeBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _inputShadowDecoration(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D131D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Charge',
              style: TextStyle(
                color: Color(0xFFE9EEF8),
                fontWeight: FontWeight.w800,
              ),
            ),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTabs extends StatelessWidget {
  const _OrderTabs({required this.selected, required this.onChanged});

  static const labels = [
    'All',
    'Pending',
    'Processing',
    'Completed',
    'Canceled',
  ];

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF273247)),
      ),
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: _OrderTab(
                label: label,
                active: selected == label,
                onTap: () => onChanged(label),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE71F32) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFFB8C0CE),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ReferenceOrderCard extends StatelessWidget {
  const _ReferenceOrderCard({required this.item, this.onTap});

  final OrderItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0006)
        ..rotateX(0.006),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _platformColor(item.title),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _platformColor(
                              item.title,
                            ).withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFF7F8898),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: item.statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'ID:  ${item.id}',
                      style: const TextStyle(
                        color: Color(0xFF7F8898),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.price,
                      style: const TextStyle(
                        color: Color(0xFFDDE3EF),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Color(0xFF7F8898),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFB8C0CE),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showOrderSuccessDialog(
  BuildContext context,
  String message,
) async {
  final safeMessage = message.trim().isEmpty
      ? 'Your order has been submitted successfully.'
      : message.trim();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF111722),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Order submitted',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          safeMessage,
          style: const TextStyle(
            color: Color(0xFFDDE3EF),
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Stay',
              style: TextStyle(
                color: Color(0xFFB8C0CE),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            },
            child: const Text(
              'Go to Orders',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
    },
  );
}
