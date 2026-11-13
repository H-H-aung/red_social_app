part of '../app.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _copySupportContact(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF111722),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReferenceFrame(
      title: 'Help & Support',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFFE9EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HelpHeroCard(),
          const SizedBox(height: 16),
          const _HomeSectionHeader(title: 'How can we help?'),
          const SizedBox(height: 12),
          const _HelpOptionTile(
            icon: Icons.receipt_long_outlined,
            title: 'Order Issues',
            subtitle: 'Refill, cancel, wrong link, or slow delivery support.',
            color: Color(0xFFE71F32),
          ),
          const _HelpOptionTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment & Wallet',
            subtitle: 'Deposit status, missing balance, and payment checks.',
            color: Color(0xFF7C3AED),
          ),
          const _HelpOptionTile(
            icon: Icons.verified_user_outlined,
            title: 'Account Security',
            subtitle: 'Password, OTP, login, and account verification help.',
            color: Color(0xFF229ED9),
          ),
          const SizedBox(height: 14),
          const _HomeSectionHeader(title: 'Contact Support'),
          const SizedBox(height: 12),
          _SupportContactTile(
            icon: Icons.confirmation_number_outlined,
            title: 'Support Ticket',
            subtitle: 'Open a ticket for order, wallet, or account issues.',
            color: const Color(0xFFE71F32),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TicketActionPage())),
          ),
          _SupportContactTile(
            icon: Icons.mail_outline_rounded,
            title: 'Support Email',
            subtitle: 'support@redsitesocial.com',
            color: const Color(0xFF229ED9),
            onTap: () => _copySupportContact(
              context,
              'support@redsitesocial.com',
              'Support email copied.',
            ),
          ),
          _SupportContactTile(
            icon: Icons.telegram_rounded,
            title: 'Telegram Support',
            subtitle: '@RedSiteSocialSupport',
            color: const Color(0xFF2AABEE),
            onTap: () => _copySupportContact(
              context,
              '@RedSiteSocialSupport',
              'Telegram username copied.',
            ),
          ),
          const SizedBox(height: 14),
          const _HomeSectionHeader(title: 'FAQ'),
          const SizedBox(height: 12),
          const _FaqCard(),
        ],
      ),
    );
  }
}

class _HelpHeroCard extends StatelessWidget {
  const _HelpHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE71F32).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE71F32).withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFE71F32),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose a topic below or open a support ticket for direct assistance.',
                  style: TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _HelpOptionTile extends StatelessWidget {
  const _HelpOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF7F8898)),
        ],
      ),
    );
  }
}

class _SupportContactTile extends StatelessWidget {
  const _SupportContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: _panelDecoration(),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.24)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF8B95A7),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7F8898),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: const Column(
        children: [
          _FaqRow(
            question: 'How long does an order take?',
            answer:
                'Most services start within minutes, but delivery time depends on the service type.',
          ),
          Divider(height: 22, color: Color(0xFF1A2433)),
          _FaqRow(
            question: 'Can I cancel an order?',
            answer:
                'You can request cancellation while the order is pending or processing.',
          ),
          Divider(height: 22, color: Color(0xFF1A2433)),
          _FaqRow(
            question: 'What if my balance is missing?',
            answer:
                'Open a payment ticket with your transaction screenshot or reference number.',
          ),
        ],
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          answer,
          style: const TextStyle(
            color: Color(0xFF7F8898),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
