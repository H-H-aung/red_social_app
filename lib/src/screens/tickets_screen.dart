part of '../app.dart';

class TicketActionPage extends StatefulWidget {
  const TicketActionPage({super.key, this.showBack = true});

  final bool showBack;

  @override
  State<TicketActionPage> createState() => _TicketActionPageState();
}

class _TicketActionPageState extends State<TicketActionPage> {
  static const _categories = ['Orders', 'Payments', 'Account'];
  static const _requestTypes = ['Refill', 'Cancel', 'Wrong Link', 'Refund'];

  String _category = _categories.first;
  String _requestType = _requestTypes.first;
  late Future<ApiResult<List<TicketItem>>> _ticketsFuture;
  final _orderIdController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _loadTickets();
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<ApiResult<List<TicketItem>>> _loadTickets() {
    if (UserSession.user?.token.isNotEmpty != true) {
      return Future.value(
        const ApiResult(
          success: false,
          message: 'Please login to view tickets.',
        ),
      );
    }
    return const TicketsApi().myTickets();
  }

  Future<void> _refreshTickets() async {
    setState(() => _ticketsFuture = _loadTickets());
    await _ticketsFuture;
  }

  Future<void> _submitTicket() async {
    final orderId = _orderIdController.text.trim();
    final message = _messageController.text.trim();

    if (UserSession.user?.token.isNotEmpty != true) {
      _showMessage('Please login to submit a ticket.');
      return;
    }
    if (_category == 'Orders' && orderId.isEmpty) {
      _showMessage('Please enter your order ID.');
      return;
    }
    if (message.isEmpty) {
      _showMessage('Please write your message.');
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await const TicketsApi().create(
      category: _category,
      requestType: _requestType,
      orderId: orderId,
      message: message,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showMessage(result.message);
    if (result.success) {
      _orderIdController.clear();
      _messageController.clear();
      await _refreshTickets();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Ticket',
      onRefresh: _refreshTickets,
      leading: widget.showBack
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFE9EEF8),
              ),
            )
          : null,
      trailing: IconButton(
        onPressed: () {
          _refreshTickets();
        },
        icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownShell(
            label: 'Category',
            value: _category,
            items: _categories,
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 12),
          _DropdownShell(
            label: 'Request Type',
            value: _requestType,
            items: _requestTypes,
            onChanged: (value) => setState(() => _requestType = value),
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Order ID',
            hint: 'Example: 58241',
            icon: Icons.tag_rounded,
            controller: _orderIdController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: 'Message',
            hint: 'Write your message',
            icon: Icons.message_outlined,
            controller: _messageController,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          _TicketSubmitButton(
            onPressed: _submitTicket,
            isSubmitting: _isSubmitting,
          ),
          const SizedBox(height: 22),
          const _HomeSectionHeader(title: 'Recent Tickets'),
          const SizedBox(height: 12),
          FutureBuilder<ApiResult<List<TicketItem>>>(
            future: _ticketsFuture,
            builder: (context, snapshot) {
              final result = snapshot.data;
              final tickets = result?.data ?? const <TicketItem>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _TicketsLoadingState();
              }
              if (result?.success != true && tickets.isEmpty) {
                return _TicketsMessageState(
                  title: 'Unable to load tickets',
                  message: result?.message ?? 'Please try again.',
                  onRefresh: () {
                    _refreshTickets();
                  },
                );
              }
              if (tickets.isEmpty) return const _TicketsEmptyState();
              return Column(
                children: [
                  for (final item in tickets) _TicketHistoryTile(item: item),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TicketsLoadingState extends StatelessWidget {
  const _TicketsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
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
            'Loading tickets...',
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

class _TicketsEmptyState extends StatelessWidget {
  const _TicketsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: _panelDecoration(),
      child: const Column(
        children: [
          Icon(Icons.confirmation_number_outlined, color: Color(0xFF7F8898)),
          SizedBox(height: 10),
          Text(
            'No tickets yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Submitted tickets will show here.',
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

class _TicketsMessageState extends StatelessWidget {
  const _TicketsMessageState({
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
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
