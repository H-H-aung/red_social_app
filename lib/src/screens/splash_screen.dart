part of '../app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fade;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();
    CatalogApi.warmUp();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    fade = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    scale = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 520),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _DepthBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.78,
                  colors: [
                    const Color(0xFFE71F32).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: fade,
                child: ScaleTransition(
                  scale: scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        padding: const EdgeInsets.all(6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF05080F),
                          border: Border.all(
                            color: const Color(0xFFE71F32),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE71F32,
                              ).withValues(alpha: 0.42),
                              blurRadius: 34,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.48),
                              blurRadius: 24,
                              offset: const Offset(8, 14),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.06),
                              blurRadius: 1,
                              offset: const Offset(-1, -1),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/Logo/red_social 6.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFE71F32),
                                  size: 42,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'RED SOCIAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Social & game services',
                        style: TextStyle(
                          color: Color(0xFF7F8898),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: 128,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Color(0xFF151D2A),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE71F32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
