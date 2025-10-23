import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  static const separator = '.'; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is null or empty
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '0', selection: TextSelection.collapsed(offset: 1));
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) && oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Remove leading '0' if not empty
    if (newValueText.startsWith('0') && newValueText.length > 1) {
      newValueText = newValueText.substring(1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex = newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(offset: newString.length - selectionIndex),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}

String formatMoney(dynamic number) {
  if (number is num) {
    final formatter = NumberFormat("#,###", "id-ID");
    return formatter.format(number);
  } else if (number is String) {
    try {
      final numericValue = double.parse(number);
      final formatter = NumberFormat("#,###", "id-ID");
      return formatter.format(numericValue);
    } catch (e) {
      return "-";
    }
  }

  return "-";
}

String removeComma(String value) {
  return value.replaceAll('.', '');
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class AlphabeticInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z *]'), '');

    final int selectionIndex = newText.length;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

formatingNumber(String number) {
  final NumberFormat numberFormat = NumberFormat('#,###', 'en_US');
  String formattedText = '';
  if (number.isNotEmpty) {
    String cleanedValue = number.replaceAll(',', '');
    formattedText = numberFormat.format(int.tryParse(cleanedValue) ?? 0);
  }
  return formattedText.replaceAll(',', '.');
}

String trimEndText(String text, int count) {
  // Trim the last 'count' characters from the text
  return text.length > count ? text.substring(0, text.length - count) : text;
}

bool endsWithZero(String text) {
  // Regular expression to match the number at the end of the text
  final RegExp regExp = RegExp(r'(\d+)$');
  final Match? match = regExp.firstMatch(text);

  if (match != null) {
    final int number = int.parse(match.group(0)!);
    return number == 0;
  }

  return false;
}

String trimErrorMessage(String exceptionMessage) {
  // Define a regex pattern to match the error message after "Error: Exception:"
  final regex = RegExp(r'Error: Exception: (.*)');
  final match = regex.firstMatch(exceptionMessage);

  // If a match is found, return the captured group, otherwise return the original message
  if (match != null && match.groupCount >= 1) {
    return match.group(1)?.trim() ?? exceptionMessage;
  }
  return exceptionMessage;
}
