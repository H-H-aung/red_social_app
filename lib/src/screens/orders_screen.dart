part of '../app.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String selectedType = 'Services';
  String selectedStatus = 'All';
  late Future<ApiResult<List<OrderItem>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<ApiResult<List<OrderItem>>> _loadOrders() {
    final user = UserSession.user;
    if (user?.token.isNotEmpty != true) {
      return Future.value(
        const ApiResult(success: false, message: 'Please login to view orders.'),
      );
    }
    if (selectedType == 'Game') {
      if (user!.id <= 0) {
        return Future.value(
          const ApiResult(
            success: false,
            message: 'Please login again to view game orders.',
          ),
        );
      }
      return const OrdersApi().gameOrders(userId: user.id);
    }
    return const OrdersApi().myOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() => _ordersFuture = _loadOrders());
    await _ordersFuture;
  }

  List<OrderItem> _filteredOrders(List<OrderItem> orders) {
    if (selectedStatus == 'All') return orders;
    final status = selectedStatus.toLowerCase();
    return orders
        .where((order) => order.status.toLowerCase().contains(status))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Orders',
      onRefresh: _refreshOrders,
      trailing: IconButton(
        onPressed: () {
          _refreshOrders();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: FutureBuilder<ApiResult<List<OrderItem>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          final result = snapshot.data;
          final orders = result?.data ?? const <OrderItem>[];
          final visibleOrders = _filteredOrders(orders);

          return Column(
            children: [
              _OrderTypeTabs(
                selected: selectedType,
                onChanged: (value) => setState(() {
                  selectedType = value;
                  selectedStatus = 'All';
                  _ordersFuture = _loadOrders();
                }),
              ),
              const SizedBox(height: 12),
              _OrderTabs(
                selected: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _OrdersLoadingState()
              else if (result?.success != true && orders.isEmpty)
                _OrdersMessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Unable to load orders',
                  message: result?.message ?? 'Please try again.',
                  actionLabel: 'Refresh',
                  onAction: () {
                    _refreshOrders();
                  },
                )
              else if (visibleOrders.isEmpty)
                _EmptyOrdersState(
                  message: selectedStatus == 'All'
                      ? 'You have no ${selectedType.toLowerCase()} orders yet.'
                      : 'This status has no orders yet.',
                )
              else
                ...visibleOrders.map(
                  (item) => _ReferenceOrderCard(
                    item: item,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(order: item),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderTypeTabs extends StatelessWidget {
  const _OrderTypeTabs({required this.selected, required this.onChanged});

  static const labels = ['Services', 'Game'];

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1018),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222B3A)),
      ),
      child: Row(
        children: [
          for (final label in labels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => onChanged(label),
                  borderRadius: BorderRadius.circular(9),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected == label
                          ? const Color(0xFFE71F32)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected == label
                            ? Colors.white
                            : const Color(0xFF9AA4B5),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
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

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF7F8898),
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'No orders found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
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

class _OrdersLoadingState extends StatelessWidget {
  const _OrdersLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      decoration: _panelDecoration(),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: Color(0xFFE71F32),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading orders...',
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

class _OrdersMessageState extends StatelessWidget {
  const _OrdersMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF7F8898), size: 34),
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
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
