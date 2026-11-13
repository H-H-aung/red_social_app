part of '../app.dart';

class _WalletMethodTile extends StatelessWidget {
  const _WalletMethodTile({required this.item});

  final WalletMethod item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Myanmar QR payment',
                  style: TextStyle(
                    color: Color(0xFF7F8898),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFFE71F32)),
        ],
      ),
    );
  }
}

class _TopUpForm extends StatefulWidget {
  const _TopUpForm({required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  State<_TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<_TopUpForm> {
  final amountController = TextEditingController();
  final transactionController = TextEditingController();
  final noteController = TextEditingController();
  bool isDownloadingQr = false;
  bool isSubmitting = false;
  XFile? screenshot;

  @override
  void dispose() {
    amountController.dispose();
    transactionController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _loginPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE71F32).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFFE71F32).withValues(alpha: 0.24),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFE71F32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Up Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Scan MMQR, then submit your payment details.',
                      style: TextStyle(
                        color: Color(0xFF7F8898),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D131D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF202A3A)),
            ),
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 230,
                      maxHeight: 230,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/Qr/red_qr_white.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'QR image could not be loaded.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFE71F32),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan this MMQR code and enter your payment details below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8B93A1),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE9EEF8),
                    side: const BorderSide(color: Color(0xFFE71F32)),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isDownloadingQr ? null : _downloadQr,
                  icon: isDownloadingQr
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE71F32),
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(
                    isDownloadingQr ? 'Saving MMQR...' : 'Download MMQR',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TextFieldShell(
            label: '',
            hint: 'amount (MMK)',
            icon: Icons.payments_outlined,
            controller: amountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: '',
            hint: 'transaction ID / reference',
            icon: Icons.receipt_long_outlined,
            controller: transactionController,
          ),
          const SizedBox(height: 12),
          _TextFieldShell(
            label: '',
            hint: 'note',
            icon: Icons.note_alt_outlined,
            controller: noteController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE9EEF8),
              side: const BorderSide(color: Color(0xFF253145)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: _pickScreenshot,
            icon: Icon(
              screenshot == null
                  ? Icons.image_outlined
                  : Icons.check_circle_rounded,
            ),
            label: Text(
              screenshot == null ? 'Upload Screenshot' : screenshot!.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE71F32),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: isSubmitting ? null : _submitTopUp,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              isSubmitting ? 'Submitting...' : 'Submit Top Up',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickScreenshot() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => screenshot = picked);
    } catch (_) {
      _showMessage('Could not select screenshot. Please try again.');
    }
  }

  Future<void> _downloadQr() async {
    setState(() => isDownloadingQr = true);

    try {
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        _showMessage('Gallery permission is required to save MMQR.');
        return;
      }

      final data = await rootBundle.load('assets/Qr/red_qr_white.png');
      await Gal.putImageBytes(
        data.buffer.asUint8List(),
        name: 'Red_Social_MMQR',
      );
      _showMessage('MMQR saved to your Gallery.');
    } catch (_) {
      _showMessage('Could not save MMQR. Please try again.');
    } finally {
      if (mounted) setState(() => isDownloadingQr = false);
    }
  }

  Future<void> _submitTopUp() async {
    if (UserSession.user?.token.isNotEmpty != true) {
      _showMessage('Please login to submit top up.');
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid MMK amount.');
      return;
    }

    if (transactionController.text.trim().isEmpty) {
      _showMessage('Please enter transaction ID or reference.');
      return;
    }

    final selectedScreenshot = screenshot;
    if (selectedScreenshot == null) {
      _showMessage('Please upload your payment screenshot.');
      return;
    }

    setState(() => isSubmitting = true);
    final result = await const WalletApi().submitTopUp(
      amount: amount,
      transactionId: transactionController.text.trim(),
      note: noteController.text.trim(),
      screenshot: selectedScreenshot,
    );
    if (!mounted) return;
    setState(() => isSubmitting = false);

    _showMessage(result.message);
    if (result.success) {
      amountController.clear();
      transactionController.clear();
      noteController.clear();
      setState(() => screenshot = null);
      widget.onSubmitted();
    }
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final WalletTransaction item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: item.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.date,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7F8898),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (item.status.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.statusColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            item.amount,
            style: TextStyle(color: item.color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
