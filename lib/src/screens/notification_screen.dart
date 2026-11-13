part of '../app.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Notification',
      leading: _CircleBackButton(onTap: () => Navigator.of(context).pop()),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NotificationOverview(),
          SizedBox(height: 16),
          _NotificationEmptyState(),
        ],
      ),
    );
  }
}

class _NotificationOverview extends StatelessWidget {
  const _NotificationOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Color(0xFFE71F32), size: 21),
              SizedBox(width: 8),
              Text(
                'Overall',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _NotificationStatCard(
                  label: 'All',
                  value: '0',
                  icon: Icons.notifications_none_rounded,
                  color: Color(0xFFE71F32),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _NotificationStatCard(
                  label: 'Unread',
                  value: '0',
                  icon: Icons.mark_email_unread_outlined,
                  color: Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: _NotificationStatCard(
                  label: 'Orders',
                  value: '0',
                  icon: Icons.receipt_long_outlined,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _NotificationStatCard(
                  label: 'System',
                  value: '0',
                  icon: Icons.settings_suggest_outlined,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationStatCard extends StatelessWidget {
  const _NotificationStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1622),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8D97A8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE71F32).withValues(alpha: 0.28),
                  const Color(0xFF101722),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFE71F32).withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFFFF6A74),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Order updates, wallet alerts, ticket replies and system messages will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8D97A8),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF101722),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 17,
        ),
      ),
    );
  }
}
