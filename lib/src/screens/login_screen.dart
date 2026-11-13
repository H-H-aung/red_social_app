part of '../app.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _DepthBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: const _LoginCard(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DepthBackground extends StatelessWidget {
  const _DepthBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackdropPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF05080F), Color(0xFF080D16), Color(0xFF10131E)],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = const Color(0xFFE71F32).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 44
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawLine(
      Offset(-size.width * 0.08, size.height * 0.18),
      Offset(size.width * 0.34, size.height * 0.05),
      glowPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.92),
      Offset(size.width * 1.06, size.height * 0.76),
      glowPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF1A2130).withValues(alpha: 0.42)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 34) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    final accent = Paint()
      ..color = const Color(0xFFE11D2E).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.20)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.09,
        size.width * 0.56,
        size.height * 0.20,
        size.width * 0.76,
        size.height * 0.10,
      );
    canvas.drawPath(path, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  bool obscure = true;
  bool confirmObscure = true;
  bool isSignup = false;
  bool otpRequested = false;
  bool otpVerified = false;
  bool requestingOtp = false;
  bool submitting = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final otpController = TextEditingController();
  final authApi = const AuthApi();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isSignup ? 'Sign Up' : 'Login';

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 26),
      decoration: _loginPanelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _LoginLogo()),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 26),
          if (isSignup) ...[
            _TextFieldShell(
              label: '',
              hint: 'username',
              icon: Icons.person_outline,
              controller: usernameController,
            ),
            const SizedBox(height: 16),
          ],
          _TextFieldShell(
            label: '',
            hint: 'user@gmail.com',
            icon: Icons.mail_outline,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (!isSignup) return;
              setState(() {
                otpRequested = false;
                otpVerified = false;
                otpController.clear();
              });
            },
          ),
          const SizedBox(height: 16),
          if (isSignup) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TextFieldShell(
                    label: '',
                    hint: 'email OTP code',
                    icon: Icons.verified_user_outlined,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => otpVerified = false),
                  ),
                ),
                const SizedBox(width: 10),
                _OtpActionButton(
                  label: requestingOtp
                      ? '...'
                      : otpRequested
                      ? 'Resend'
                      : 'OTP',
                  onPressed: requestingOtp ? null : _requestOtp,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              otpVerified
                  ? 'Email verified'
                  : otpRequested
                  ? 'OTP sent. Enter the 6 digit code from email.'
                  : 'Request OTP to verify your email.',
              style: TextStyle(
                color: otpVerified
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF7F8898),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          _TextFieldShell(
            label: '',
            hint: 'password',
            icon: Icons.lock_outline,
            controller: passwordController,
            obscureText: obscure,
            suffix: IconButton(
              tooltip: obscure ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          if (isSignup) ...[
            const SizedBox(height: 16),
            _TextFieldShell(
              label: '',
              hint: 'confirm password',
              icon: Icons.lock_outline,
              controller: confirmController,
              obscureText: confirmObscure,
              suffix: IconButton(
                tooltip: confirmObscure ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => confirmObscure = !confirmObscure),
                icon: Icon(
                  confirmObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFFE11D2E), fontSize: 12),
                ),
              ),
            ),
          if (isSignup) const SizedBox(height: 18),
          const SizedBox(height: 8),
          _GradientButton(
            label: submitting
                ? 'Please wait...'
                : isSignup
                ? 'Create Account'
                : 'Login',
            onPressed: submitting ? null : _submitAuth,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSignup
                    ? 'Already have an account?'
                    : "Don't have an account?",
                style: const TextStyle(color: Color(0xFF8B93A1), fontSize: 12),
              ),
              TextButton(
                onPressed: submitting
                    ? null
                    : () => setState(() {
                        isSignup = !isSignup;
                        otpRequested = false;
                        otpVerified = false;
                        otpController.clear();
                      }),
                child: Text(
                  isSignup ? 'Sign in' : 'Sign up',
                  style: const TextStyle(
                    color: Color(0xFFF60505),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestOtp() async {
    final email = emailController.text.trim();
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!validEmail) {
      _showOtpSnack('Please enter a valid email address.');
      return;
    }

    setState(() => requestingOtp = true);
    final result = await authApi.requestSignupCode(email);
    if (!mounted) return;

    setState(() {
      requestingOtp = false;
      otpRequested = result.success;
      otpVerified = false;
      otpController.clear();
    });
    _showOtpSnack(result.message);
  }

  Future<void> _submitAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!validEmail) {
      _showOtpSnack('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showOtpSnack('Password must be at least 6 characters.');
      return;
    }

    setState(() => submitting = true);

    final ApiResult<Map<String, dynamic>> result;
    if (isSignup) {
      final username = usernameController.text.trim();
      final code = otpController.text.trim();
      if (username.isEmpty) {
        setState(() => submitting = false);
        _showOtpSnack('Please enter your username.');
        return;
      }
      if (password != confirmController.text) {
        setState(() => submitting = false);
        _showOtpSnack('Passwords do not match.');
        return;
      }
      if (!otpRequested || code.length != 6) {
        setState(() => submitting = false);
        _showOtpSnack('Please enter the 6 digit email OTP.');
        return;
      }
      result = await authApi.verifySignupCode(
        username: username,
        email: email,
        password: password,
        code: code,
      );
    } else {
      result = await authApi.login(email: email, password: password);
    }

    if (!mounted) return;
    setState(() {
      submitting = false;
      if (isSignup && result.success) otpVerified = true;
    });

    if (!result.success) {
      _showOtpSnack(result.message);
      return;
    }

    UserSession.saveFromApi(result.data);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
  }

  void _showOtpSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF111722),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _ForgotPasswordDialog(),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool otpRequested = false;
  bool otpVerified = false;
  bool requestingOtp = false;
  bool resetting = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  final authApi = const AuthApi();

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111722),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Forgot Password',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AuthLogo(size: 72),
            const SizedBox(height: 14),
            const Text(
              'Verify your email with OTP, then create a new password.',
              style: TextStyle(color: Color(0xFF8B93A1), fontSize: 13),
            ),
            const SizedBox(height: 16),
            _TextFieldShell(
              label: '',
              hint: 'user@gmail.com',
              icon: Icons.mail_outline,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                setState(() {
                  otpRequested = false;
                  otpVerified = false;
                  otpController.clear();
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TextFieldShell(
                    label: '',
                    hint: 'reset OTP code',
                    icon: Icons.verified_user_outlined,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() => otpVerified = value.trim().length == 6);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _OtpActionButton(
                  label: requestingOtp
                      ? '...'
                      : otpRequested
                      ? 'Resend'
                      : 'OTP',
                  onPressed: requestingOtp ? null : _requestResetOtp,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                otpVerified
                    ? 'Email verified. Enter a new password.'
                    : otpRequested
                    ? 'OTP sent. Enter the 6 digit code.'
                    : 'Request OTP to continue.',
                style: TextStyle(
                  color: otpVerified
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF7F8898),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (otpVerified) ...[
              const SizedBox(height: 14),
              _TextFieldShell(
                label: '',
                hint: 'new password',
                icon: Icons.lock_outline,
                controller: passwordController,
                obscureText: obscurePassword,
                suffix: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _TextFieldShell(
                label: '',
                hint: 'confirm new password',
                icon: Icons.lock_outline,
                controller: confirmController,
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
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF8B93A1)),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE11D2E),
          ),
          onPressed: resetting ? null : _resetPassword,
          child: Text(resetting ? 'Please wait...' : 'Reset Password'),
        ),
      ],
    );
  }

  Future<void> _requestResetOtp() async {
    final email = emailController.text.trim();
    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!validEmail) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => requestingOtp = true);
    final result = await authApi.requestForgotCode(email);
    if (!mounted) return;

    setState(() {
      requestingOtp = false;
      otpRequested = result.success;
      otpVerified = false;
      otpController.clear();
    });
    _showMessage(result.message);
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    final code = otpController.text.trim();
    if (code.length != 6) {
      _showMessage('Please enter the 6 digit OTP.');
      return;
    }
    if (passwordController.text.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }
    if (passwordController.text != confirmController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => resetting = true);
    final result = await authApi.resetPassword(
      email: email,
      code: code,
      password: passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      resetting = false;
      otpVerified = result.success;
    });

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

class _OtpActionButton extends StatelessWidget {
  const _OtpActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE11D2E),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFE11D2E).withValues(alpha: 0.32),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return const _AuthLogo(size: 82);
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF05080F),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFE11D2E).withValues(alpha: 0.72),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44E11D2E),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/Logo/red_social 6.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.bolt_rounded, color: Color(0xFFE11D2E)),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D4D), Color(0xFFF60505), Color(0xFFC00000)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40F60505),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
