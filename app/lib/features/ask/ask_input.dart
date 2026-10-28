import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';

/// Multiline question input: 3–8 lines, counter, Enter sends, Shift+Enter adds a line (DESIGN.md §11.5).
class AskInput extends ConsumerStatefulWidget {
  const AskInput({
    super.key,
    required this.onSubmit,
    required this.busy,
    required this.invalid,
  });

  final ValueChanged<String> onSubmit;
  final bool busy, invalid;

  @override
  ConsumerState<AskInput> createState() => _AskInputState();
}

class _AskInputState extends ConsumerState<AskInput> {
  final _text = TextEditingController();
  late final _focus = FocusNode(onKeyEvent: _key);

  KeyEventResult _key(FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _send() {
    if (!widget.busy) widget.onSubmit(_text.text);
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l.askInputLabel,
          textField: true,
          child: TextField(
            controller: _text,
            focusNode: _focus,
            minLines: 3,
            maxLines: 8,
            maxLength: 500,
            buildCounter: (
              _, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
            onChanged: (_) => setState(() {}),
            style: context.text.bodyLarge,
            decoration: InputDecoration(
              hintText: l.askPlaceholder,
              errorText: widget.invalid ? l.askErrInvalid : null,
            ),
          ),
        ),
        const SizedBox(height: FsSpace.s2),
        Row(
          children: [
            Expanded(
              child: Text(
                l.askCounter(fmt.integer(_text.text.length)),
                style: context.text.labelSmall!.copyWith(
                  color: _text.text.length > 500 ? c.danger : null,
                ),
              ),
            ),
            FsButton(
              label: l.askButton,
              icon: Icons.send_rounded,
              loading: widget.busy,
              onPressed: _send,
            ),
          ],
        ),
      ],
    );
  }
}
