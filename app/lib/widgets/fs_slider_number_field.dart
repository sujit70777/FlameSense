import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';

/// 96 × 36 numeric entry for an [FsSlider]; invalid input shows a danger border
/// and "Enter a number between {min} and {max}." (DESIGN.md §9.7, §12.4).
class FsSliderNumberField extends StatefulWidget {
  const FsSliderNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.decimals,
    required this.format,
    required this.onSubmitted,
    this.enabled = true,
  });

  /// Display units.
  final double value, min, max;
  final String label;
  final int decimals;
  final FsFormat format;
  final ValueChanged<double> onSubmitted;
  final bool enabled;

  @override
  State<FsSliderNumberField> createState() => _FsSliderNumberFieldState();
}

class _FsSliderNumberFieldState extends State<FsSliderNumberField> {
  late final TextEditingController _text = TextEditingController(
    text: _display(),
  );
  final _focus = FocusNode();
  String? _error;

  String _display() => widget.format.fixed(widget.value, widget.decimals);

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _submit(_text.text);
    });
  }

  @override
  void didUpdateWidget(FsSliderNumberField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.value != widget.value) _text.text = _display();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String s) {
    final v = FsFormat.parse(s);
    final tolerance = (widget.max - widget.min).abs() * 1e-9;
    if (v == null || v < widget.min - tolerance || v > widget.max + tolerance) {
      setState(() {
        _error = AppLocalizations.of(context).numErrRange(
          widget.format.sig(widget.min),
          widget.format.sig(widget.max),
        );
      });
      return;
    }
    setState(() => _error = null);
    widget.onSubmitted(v.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: FsSize.numberField,
          height: FsSize.numberFieldHeight,
          child: Semantics(
            label: widget.label,
            child: TextField(
              controller: _text,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textAlign: TextAlign.right,
              style: context.nums.sm,
              onSubmitted: _submit,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FsSpace.s2,
                  vertical: FsSpace.s2,
                ),
                enabledBorder: _error == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FsRadius.sm),
                        borderSide: BorderSide(color: c.danger),
                      ),
              ),
            ),
          ),
        ),
        if (_error != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Padding(
              padding: const EdgeInsets.only(top: FsSpace.s1),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: context.text.labelSmall!.copyWith(color: c.danger),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
