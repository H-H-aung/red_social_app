part of '../app.dart';

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: _DepthBackground()),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      child,
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

class _HomeFrame extends StatelessWidget {
  const _HomeFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: _DepthBackground()),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16, 14, 16, 70 + keyboardBottom),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFrame extends StatelessWidget {
  const _ReferenceFrame({
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    this.onRefresh,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;

    final scrollView = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 14, 16, 70 + keyboardBottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: leading ?? const SizedBox(width: 48),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: trailing ?? const SizedBox(width: 48),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: _DepthBackground()),
          SafeArea(
            child: onRefresh == null
                ? scrollView
                : RefreshIndicator(
                    color: const Color(0xFFE71F32),
                    backgroundColor: const Color(0xFF111722),
                    onRefresh: onRefresh!,
                    child: scrollView,
                  ),
          ),
        ],
      ),
    );
  }
}
