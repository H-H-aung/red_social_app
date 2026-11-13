part of '../app.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  static const methods = [
    WalletMethod(
      icon: Icons.qr_code_2_rounded,
      label: 'MMQR',
      color: Color(0xFFE71F32),
    ),
  ];

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Future<ApiResult<List<WalletTransaction>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _loadTransactions();
  }

  Future<ApiResult<List<WalletTransaction>>> _loadTransactions() {
    if (UserSession.user?.token.isNotEmpty != true) {
      return Future.value(
        const ApiResult(
          success: false,
          message: 'Please login to view wallet transactions.',
        ),
      );
    }
    return const WalletApi().transactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() => _transactionsFuture = _loadTransactions());
    await _transactionsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Wallet',
      onRefresh: _refreshTransactions,
      trailing: IconButton(
        onPressed: () {
          _refreshTransactions();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<AppUser?>(
            valueListenable: UserSession.current,
            builder: (context, user, _) {
              return _ReferenceBalanceCard(
                user: user ?? AccountPage._guestUser,
              );
            },
          ),
          const SizedBox(height: 22),
          const _HomeSectionHeader(title: 'MMQR Deposit'),
          const SizedBox(height: 12),
          ...WalletPage.methods.map((item) => _WalletMethodTile(item: item)),
          const SizedBox(height: 12),
          _TopUpForm(
            onSubmitted: () {
              _refreshTransactions();
            },
          ),
          const SizedBox(height: 20),
          const _HomeSectionHeader(
            title: 'Recent Transactions',
          ),
          const SizedBox(height: 12),
          FutureBuilder<ApiResult<List<WalletTransaction>>>(
            future: _transactionsFuture,
            builder: (context, snapshot) {
              final result = snapshot.data;
              final transactions = result?.data ?? const <WalletTransaction>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _WalletLoadingState();
              }
              if (result?.success != true && transactions.isEmpty) {
                return _WalletMessageState(
                  title: 'Unable to load transactions',
                  message: result?.message ?? 'Please try again.',
                  onRefresh: () {
                    _refreshTransactions();
                  },
                );
              }
              if (transactions.isEmpty) return const _WalletEmptyState();
              return Column(
                children: [
                  for (final item in transactions) _TransactionTile(item: item),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WalletLoadingState extends StatelessWidget {
  const _WalletLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: const Column(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Color(0xFFE71F32),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading transactions...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletEmptyState extends StatelessWidget {
  const _WalletEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF7F8898)),
          SizedBox(height: 10),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your MMQR top-up requests will show here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7F8898),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletMessageState extends StatelessWidget {
  const _WalletMessageState({
    required this.title,
    required this.message,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Color(0xFF7F8898)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7F8898),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onRefresh,
            child: const Text(
              'Refresh',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
