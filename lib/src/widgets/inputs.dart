part of '../app.dart';

class _TextFieldShell extends StatelessWidget {
  const _TextFieldShell({
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _inputShadowDecoration(),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        enabled: enabled,
        style: const TextStyle(fontSize: 16, color: Color(0xFFDDE3EF)),
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6D7787)),
          prefixIcon: Icon(icon, color: const Color(0xFFE11D2E), size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFF0D131D),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE11D2E), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _DropdownShell extends StatefulWidget {
  const _DropdownShell({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String>? onChanged;

  @override
  State<_DropdownShell> createState() => _DropdownShellState();
}

class _DropdownShellState extends State<_DropdownShell> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = _normalizedValue();
  }

  @override
  void didUpdateWidget(covariant _DropdownShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.items != widget.items) {
      _selectedValue = _normalizedValue();
    }
  }

  String _normalizedValue() {
    if (widget.items.contains(widget.value)) return widget.value;
    return widget.items.isEmpty ? '' : widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.items.isEmpty ? null : _openSelector,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _inputShadowDecoration().copyWith(
            color: const Color(0xFF0D131D),
            border: Border.all(color: const Color(0xFF202B3C)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE71F32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFFE71F32),
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Color(0xFF7F8898),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE9EEF8),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFE71F32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF384154),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose ${widget.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    itemCount: widget.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final active = item == _selectedValue;

                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            constraints: const BoxConstraints(minHeight: 58),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF29111A)
                                  : const Color(0xFF111824),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFE71F32)
                                    : const Color(0xFF202B3C),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? const Color(0xFFE71F32)
                                        : const Color(0xFF1A2433),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(
                                    active
                                        ? Icons.check_rounded
                                        : Icons.chevron_right_rounded,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF7F8898),
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Color(0xFFE9EEF8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == _selectedValue || !mounted) return;
    setState(() => _selectedValue = selected);
    widget.onChanged?.call(selected);
  }
}
