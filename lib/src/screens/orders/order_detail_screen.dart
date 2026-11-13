part of '../../app.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Order Detail',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderDetailHero(order: order),
          const SizedBox(height: 16),
          _OrderProgressCard(order: order),
          const SizedBox(height: 16),
          _OrderDetailInfoCard(order: order),
          const SizedBox(height: 16),
          _OrderSupportCard(order: order),
        ],
      ),
    );
  }
}

class _OrderDetailHero extends StatelessWidget {
  const _OrderDetailHero({required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(order.title);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomLeft,
          radius: 1.28,
          colors: [
            color.withValues(alpha: 0.92),
            const Color(0xFF6F1420),
            const Color(0xFF111722),
            const Color(0xFF0B1018),
          ],
          stops: const [0.0, 0.32, 0.72, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -18,
            child: Icon(
              order.icon,
              size: 112,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(order.icon, color: Colors.white, size: 29),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          order.id,
                          style: const TextStyle(
                            color: Color(0xFFB8C0CE),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _OrderDetailMetric(label: 'Charge', value: order.price),
                  const SizedBox(width: 10),
                  _OrderDetailMetric(label: 'Quantity', value: order.subtitle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderDetailMetric extends StatelessWidget {
  const _OrderDetailMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1018).withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7F8898),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderProgressCard extends StatelessWidget {
  const _OrderProgressCard({required this.order});

  final OrderItem order;

  double get progress {
    switch (order.status) {
      case 'Completed':
        return 1;
      case 'Processing':
        return 0.62;
      case 'Pending':
        return 0.28;
      default:
        return 0.45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Order Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: order.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: const Color(0xFF1A2433),
              valueColor: AlwaysStoppedAnimation<Color>(order.statusColor),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ProgressLabel(label: 'Created'),
              _ProgressLabel(label: 'Processing'),
              _ProgressLabel(label: 'Done'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF7F8898),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _OrderDetailInfoCard extends StatelessWidget {
  const _OrderDetailInfoCard({required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HomeSectionHeader(title: 'Order Information'),
        const SizedBox(height: 12),
        _OrderInfoTile(
          icon: Icons.tag_rounded,
          label: 'Order ID',
          value: order.id,
          color: const Color(0xFFE71F32),
        ),
        _OrderInfoTile(
          icon: order.icon,
          label: 'Service',
          value: order.title,
          color: _platformColor(order.title),
        ),
        _OrderInfoTile(
          icon: Icons.numbers_rounded,
          label: 'Quantity',
          value: order.subtitle,
          color: const Color(0xFF7C3AED),
        ),
        _OrderInfoTile(
          icon: Icons.schedule_rounded,
          label: 'Created',
          value: order.time,
          color: const Color(0xFF229ED9),
        ),
        const _OrderInfoTile(
          icon: Icons.link_rounded,
          label: 'Link',
          value: 'https://profile-link/example',
          color: Color(0xFF22C55E),
          multiLine: true,
        ),
      ],
    );
  }
}

class _OrderInfoTile extends StatelessWidget {
  const _OrderInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.multiLine = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D131D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF202A3A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(5, 9),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.03),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: multiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE9EEF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1.28,
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

class _OrderSupportCard extends StatelessWidget {
  const _OrderSupportCard({required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE71F32).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFFE71F32),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Open a ticket for this order.',
                  style: TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TicketActionPage())),
            icon: const Icon(Icons.chevron_right_rounded),
            color: const Color(0xFFE9EEF8),
          ),
        ],
      ),
    );
  }
}
