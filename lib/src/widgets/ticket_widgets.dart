part of '../app.dart';

class _TicketSubmitButton extends StatelessWidget {
  const _TicketSubmitButton({required this.onPressed, this.isSubmitting = false});

  final VoidCallback? onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE71F32),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: const Color(0xFFE71F32).withValues(alpha: 0.36),
      ),
      onPressed: isSubmitting ? null : onPressed,
      icon: Icon(isSubmitting ? Icons.hourglass_top_rounded : Icons.send_rounded, size: 18),
      label: Text(
        isSubmitting ? 'Submitting...' : 'Submit Ticket',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _TicketHistoryTile extends StatelessWidget {
  const _TicketHistoryTile({required this.item});

  final TicketItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE71F32).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE71F32).withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFE71F32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.id}  ${item.subject}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  item.time.isEmpty ? 'Just now' : item.time,
                  style: const TextStyle(color: Color(0xFF7F8898), fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(8)),
            child: Text(item.status, style: TextStyle(color: item.color, fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
