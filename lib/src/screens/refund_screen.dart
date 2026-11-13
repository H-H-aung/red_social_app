part of '../app.dart';

class RefundRequestPage extends StatelessWidget {
  const RefundRequestPage({super.key});

  static const _refunds = [
    _RefundRow(
      orderId: '#58241',
      service: 'Instagram Followers [HQ]',
      issue: 'Wrong profile link',
      amount: '\$2.45',
      status: 'Pending',
      statusColor: Color(0xFFF59E0B),
    ),
    _RefundRow(
      orderId: '#58220',
      service: 'Facebook Page Likes [HQ]',
      issue: 'Invalid page URL',
      amount: '\$2.10',
      status: 'Approved',
      statusColor: Color(0xFF22C55E),
    ),
    _RefundRow(
      orderId: '#58192',
      service: 'YouTube Subscribers [HQ]',
      issue: 'Wrong channel link',
      amount: '\$3.50',
      status: 'Rejected',
      statusColor: Color(0xFFE71F32),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Refund',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RefundInfoHeader(),
          const SizedBox(height: 18),
          const _HomeSectionHeader(title: 'Refund History'),
          const SizedBox(height: 12),
          Container(
            decoration: _loginPanelDecoration(),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF151D2A),
                ),
                dataRowMinHeight: 58,
                dataRowMaxHeight: 64,
                columnSpacing: 22,
                horizontalMargin: 14,
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(label: _RefundTableHead('Order')),
                  DataColumn(label: _RefundTableHead('Service')),
                  DataColumn(label: _RefundTableHead('Issue')),
                  DataColumn(label: _RefundTableHead('Amount')),
                  DataColumn(label: _RefundTableHead('Status')),
                ],
                rows: _refunds.map((item) => item.toDataRow()).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundInfoHeader extends StatelessWidget {
  const _RefundInfoHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _loginPanelDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: _miniBadgeDecoration(const Color(0xFFE71F32)),
            child: const Icon(
              Icons.assignment_return_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wrong Link Refund',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Approved refunds from admin will appear here.',
                  style: TextStyle(
                    color: Color(0xFF8B93A1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _RefundTableHead extends StatelessWidget {
  const _RefundTableHead(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB8C0CE),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _RefundRow {
  const _RefundRow({
    required this.orderId,
    required this.service,
    required this.issue,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  final String orderId;
  final String service;
  final String issue;
  final String amount;
  final String status;
  final Color statusColor;

  DataRow toDataRow() {
    return DataRow(
      cells: [
        DataCell(_RefundCell(orderId, strong: true)),
        DataCell(_RefundCell(service)),
        DataCell(_RefundCell(issue)),
        DataCell(_RefundCell(amount, strong: true)),
        DataCell(_RefundStatusPill(label: status, color: statusColor)),
      ],
    );
  }
}

class _RefundCell extends StatelessWidget {
  const _RefundCell(this.text, {this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: strong ? Colors.white : const Color(0xFFB8C0CE),
          fontSize: 12,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _RefundStatusPill extends StatelessWidget {
  const _RefundStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
