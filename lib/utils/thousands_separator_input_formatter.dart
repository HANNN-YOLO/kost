import 'package:flutter/services.dart';

/// Formats numeric input with Indonesian thousand separators using '.'
/// Example: 2500000 -> 2.500.000
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  static String formatDigits(String digits) {
    final clean = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      final reverseIndex = clean.length - i;
      buffer.write(clean[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  static int? tryParseInt(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = formatDigits(digitsOnly);

    final selectionEnd = newValue.selection.end.clamp(0, newText.length);
    final digitsBeforeCursor = newText
        .substring(0, selectionEnd)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    int newCursor = 0;
    int digitCount = 0;
    while (newCursor < formatted.length && digitCount < digitsBeforeCursor) {
      final ch = formatted[newCursor];
      if (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57) {
        digitCount++;
      }
      newCursor++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }
}
