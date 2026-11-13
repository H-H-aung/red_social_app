part of '../app.dart';

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 78,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF172033).withValues(alpha: 0.78),
                    const Color(0xFF0D131D).withValues(alpha: 0.72),
                    const Color(0xFF070B12).withValues(alpha: 0.76),
                  ],
                ),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.54),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: const Color(0xFFE71F32).withValues(alpha: 0.07),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 1,
                    offset: const Offset(-1, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FloatingNavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: 'Orders',
                    active: selectedIndex == 0,
                    onTap: () => onChanged(0),
                  ),
                  _FloatingNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    active: selectedIndex == 1,
                    onTap: () => onChanged(1),
                  ),
                  _FloatingNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    active: selectedIndex == 2,
                    onTap: () => onChanged(2),
                  ),
                  _FloatingNavItem(
                    icon: Icons.confirmation_number_outlined,
                    activeIcon: Icons.confirmation_number,
                    label: 'Ticket',
                    active: selectedIndex == 3,
                    onTap: () => onChanged(3),
                  ),
                  _FloatingNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    active: selectedIndex == 4,
                    onTap: () => onChanged(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHome = label == 'Home';
    final iconColor = active && isHome
        ? Colors.white
        : active
        ? const Color(0xFFE71F32)
        : const Color(0xFF747E8E);
    final labelColor = active
        ? const Color(0xFFE71F32)
        : const Color(0xFF747E8E);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 74,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: active && isHome
                    ? 50
                    : active
                    ? 38
                    : 34,
                height: active && isHome
                    ? 50
                    : active
                    ? 38
                    : 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isHome
                              ? const [
                                  Color(0xFFFF6A74),
                                  Color(0xFFE71F32),
                                  Color(0xFF9F111E),
                                ]
                              : const [Color(0x33FF6A74), Color(0x22E71F32)],
                        )
                      : null,
                  color: active ? null : Colors.transparent,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFE71F32,
                            ).withValues(alpha: isHome ? 0.38 : 0.18),
                            blurRadius: isHome ? 22 : 14,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  active ? activeIcon : icon,
                  color: iconColor,
                  size: active && isHome ? 27 : 23,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
