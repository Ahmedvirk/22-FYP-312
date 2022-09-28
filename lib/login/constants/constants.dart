import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Color> color = [Colors.blue, Colors.black];
Color iconColor = Colors.blue;
Color textColor = Colors.blue;
const String SIGN_IN = 'signin';
const String SIGN_UP = 'signup';
const String SPLASH_SCREEN = 'splashscreen';

class MaskTextInputFormatter extends TextInputFormatter {
  final int maskLength;
  final Map<String, List<int>> separatorBoundries;

  MaskTextInputFormatter({
    String mask = "xxxx-xxxxxxx",
    List<String> separators = const ["-"],
  })  : separatorBoundries = {
          for (var v in separators)
            v: mask
                .split("")
                .asMap()
                .entries
                .where((entry) => entry.value == v)
                .map((e) => e.key)
                .toList()
        },
        maskLength = mask.length;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    final int oldTextLength = oldValue.text.length;
    // removed char
    if (newTextLength < oldTextLength) return newValue;
    // maximum amount of chars
    if (oldTextLength == maskLength) return oldValue;

    // masking
    final StringBuffer newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    // extra boundaries check
    final separatorEntry1 = separatorBoundries.entries
        .firstWhere((entry) => entry.value.contains(oldTextLength));
    if (separatorEntry1 != null) {
      newText.write(oldValue.text + separatorEntry1.key);
      selectionIndex++;
    } else {
      newText.write(oldValue.text);
    }
    // write the char
    newText.write(newValue.text[newValue.text.length - 1]);

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
