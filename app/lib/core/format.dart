import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Locale-aware number formatting (DESIGN.md §4.4, §10.1): 3 significant
/// digits by default and Bangla digits when the locale is `bn`.
class FsFormat {
  /// Formatter for [locale] ('en' or 'bn').
  FsFormat(this.locale);

  final String locale;

  static const _superscripts = {
    '-': '⁻',
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
  };

  /// [value] with [digits] significant digits, e.g. 3.42, 101, 0.0123.
  String sig(double value, {int digits = 3}) {
    if (!value.isFinite) return '—';
    if (value == 0) return _digits('0');
    final magnitude = (math.log(value.abs()) / math.ln10).floor();
    final decimals = math.max(0, digits - 1 - magnitude);
    final rounded = double.parse(value.toStringAsFixed(math.min(decimals, 12)));
    final f = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = decimals;
    return f.format(rounded);
  }

  /// Fixed number of decimals, locale digits (used for slider fields and %).
  String fixed(double value, int decimals) {
    final f = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return f.format(value);
  }

  /// Integer with locale digits.
  String integer(num value) =>
      NumberFormat.decimalPattern(locale).format(value.round());

  /// A 0–1 probability as whole percentage points, e.g. 0.72 → "72".
  String percentPoints(double p) => integer(p * 100);

  /// Gravity in g: "1", "0.378", or "1.2 × 10⁻³" for small values.
  String gravity(double g) {
    if (g >= 0.01) return sig(g);
    final exp = (math.log(g) / math.ln10).floor();
    final mantissa = g / math.pow(10, exp);
    final sup = exp
        .toString()
        .split('')
        .map((c) => _superscripts[c] ?? c)
        .join();
    if ((mantissa - 1).abs() < 0.05) return '${_digits('10')}$sup';
    return '${sig(mantissa, digits: 2)} × ${_digits('10')}$sup';
  }

  /// Signed value with an explicit "+" or "−".
  String signed(double value, {int digits = 2}) {
    final body = sig(value.abs(), digits: digits);
    if (value > 0) return '+$body';
    if (value < 0) return '−$body';
    return body;
  }

  /// Short UTC date, e.g. 2026-11-12 (locale digits).
  String date(DateTime t) =>
      _digits(DateFormat('yyyy-MM-dd').format(t.toUtc()));

  /// Replaces ASCII digits with locale digits.
  String _digits(String s) {
    if (locale != 'bn') return s;
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return s.replaceAllMapped(RegExp('[0-9]'), (m) => bn[int.parse(m[0]!)]);
  }

  /// Public form of digit localisation for preformatted strings.
  String digits(String s) => _digits(s);

  /// Parses a user-typed number in either digit system; null if invalid.
  static double? parse(String input) {
    const bn = '০১২৩৪৫৬৭৮৯';
    final ascii = input.trim().split('').map((c) {
      final i = bn.indexOf(c);
      return i >= 0 ? '$i' : c;
    }).join();
    return double.tryParse(ascii.replaceAll(',', ''));
  }
}
