part of '../app.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _fillControllers(UserSession.user);
    _refreshProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _fillControllers(AppUser? user) {
    usernameController.text = user?.username ?? '';
    emailController.text = user?.email ?? '';
    phoneController.text = user?.phone ?? '';
  }

  Future<void> _refreshProfile() async {
    final token = UserSession.user?.token ?? '';
    if (token.isEmpty) return;
    final result = await const AccountApi().profile();
    if (!mounted || !result.success || result.data == null) return;
    _fillControllers(result.data);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: UserSession.current,
      builder: (context, user, _) {
        final account = user ?? AccountPage._guestUser;
        return _ReferenceFrame(
          title: 'My Profile',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFE9EEF8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
            padding: const EdgeInsets.all(18),
            decoration: _loginPanelDecoration(),
            child: Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF101722),
                    border: Border.all(
                      color: const Color(0xFFE71F32),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE71F32).withValues(alpha: 0.34),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.42),
                        blurRadius: 16,
                        offset: const Offset(6, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 54,
                    color: Color(0xFFE9EEF8),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  account.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  account.email,
                  style: TextStyle(
                    color: Color(0xFF8B93A1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStatChip(
                        label: 'Orders',
                        value: account.orders.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatChip(
                        label: 'VIP',
                        value: '${account.discountPercent}%',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProfileStatChip(
                        label: 'Balance',
                        value: '\$${account.balance.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _HomeSectionHeader(title: 'Account Details'),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: '',
            hint: 'username',
            icon: Icons.alternate_email_rounded,
            controller: usernameController,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: '',
            hint: 'email address',
            icon: Icons.mail_outline_rounded,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: '',
            hint: 'phone number',
            icon: Icons.phone_outlined,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: saving ? null : _saveProfile,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              saving ? 'Saving...' : 'Save Profile',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final token = UserSession.user?.token ?? '';
    if (token.isEmpty) {
      _showMessage('Please login again before saving profile.');
      return;
    }

    if (usernameController.text.trim().length < 3) {
      _showMessage('Username must be at least 3 characters.');
      return;
    }

    setState(() => saving = true);
    final result = await const AccountApi().updateProfile(
      username: usernameController.text.trim(),
      phone: phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => saving = false);
    _showMessage(result.message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF111722),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProfileStatChip extends StatelessWidget {
  const _ProfileStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D131D),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF202A3A)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF7F8898),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
