part of '../app.dart';

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(item.label);
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0007)
        ..rotateX(0.008),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: _panelDecoration(),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              bottom: -16,
              child: Icon(item.icon, size: 72, color: color.withValues(alpha: 0.11)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color.withValues(alpha: 0.92), color],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.30), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF7F8898)),
                  ],
                ),
                const Spacer(),
                Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.services} services',
                  style: const TextStyle(color: Color(0xFF7F8898), fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
