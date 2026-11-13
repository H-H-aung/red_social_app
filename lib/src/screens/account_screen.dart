part of '../app.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: UserSession.current,
      builder: (context, user, _) {
        final account = user ?? _guestUser;
        return _ReferenceFrame(
          title: 'Profile',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AccountHeader(user: account),
              const SizedBox(height: 16),
              Container(
                decoration: _panelDecoration(),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.person_outline_rounded,
                      label: 'My Profile',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileDetailPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1A2433)),
                    _ProfileMenuTile(
                      icon: Icons.support_agent_rounded,
                      label: 'Help & Support',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1A2433)),
                    _ProfileMenuTile(
                      icon: Icons.assignment_return_rounded,
                      label: 'Refund Request',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RefundRequestPage(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1A2433)),
                    _ProfileMenuTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    const Divider(height: 1, color: Color(0xFF1A2433)),
                    _ProfileMenuTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      color: const Color(0xFFE71F32),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _guestUser = AppUser(
    id: 0,
    username: 'Red Social User',
    email: 'login@example.com',
    balance: 0,
    spent: 0,
    role: 'user',
    discountPercent: 0,
  );

  static Future<void> refreshProfile(BuildContext context, AppUser user) async {
    if (user.token.isEmpty) return;
    final result = await const AccountApi().profile();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: const Color(0xFF111722),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _LogoutConfirmDialog(),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF101722),
              border: Border.all(color: const Color(0xFFE71F32), width: 2),
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
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              color: Color(0xFF7F8898),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => AccountPage.refreshProfile(context, user),
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Refresh profile'),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool submitting = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111722),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE71F32).withValues(alpha: 0.13),
                  border: Border.all(
                    color: const Color(0xFFE71F32).withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE71F32).withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFE71F32),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your current password and choose a new one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8B93A1),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            _TextFieldShell(
              label: '',
              hint: 'current password',
              icon: Icons.lock_outline_rounded,
              controller: oldPasswordController,
              obscureText: obscureOld,
              suffix: IconButton(
                tooltip: obscureOld ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => obscureOld = !obscureOld),
                icon: Icon(
                  obscureOld
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _TextFieldShell(
              label: '',
              hint: 'new password',
              icon: Icons.lock_reset_rounded,
              controller: newPasswordController,
              obscureText: obscureNew,
              suffix: IconButton(
                tooltip: obscureNew ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => obscureNew = !obscureNew),
                icon: Icon(
                  obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _TextFieldShell(
              label: '',
              hint: 'confirm new password',
              icon: Icons.verified_user_outlined,
              controller: confirmPasswordController,
              obscureText: obscureConfirm,
              suffix: IconButton(
                tooltip: obscureConfirm ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => obscureConfirm = !obscureConfirm),
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE9EEF8),
                      side: const BorderSide(color: Color(0xFF253145)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE71F32),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: submitting ? null : _changePassword,
                    child: Text(
                      submitting ? 'Saving...' : 'Save',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (oldPasswordController.text.isEmpty) {
      _showMessage('Please enter your current password.');
      return;
    }
    if (newPasswordController.text.length < 6) {
      _showMessage('New password must be at least 6 characters.');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      _showMessage('New passwords do not match.');
      return;
    }

    final token = UserSession.user?.token ?? '';
    if (token.isEmpty) {
      _showMessage('Please login again before changing password.');
      return;
    }

    setState(() => submitting = true);
    final result = await const AccountApi().changePassword(
      currentPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => submitting = false);

    if (!result.success) {
      _showMessage(result.message);
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: const Color(0xFF111722),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111722),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE71F32).withValues(alpha: 0.13),
                border: Border.all(
                  color: const Color(0xFFE71F32).withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE71F32).withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE71F32),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Logout Account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Are you sure you want to logout from RED SITE SOCIAL?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B93A1),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE9EEF8),
                    side: const BorderSide(color: Color(0xFF253145)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE71F32),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    UserSession.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
