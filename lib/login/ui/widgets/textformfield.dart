// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veterinaryapp/login/constants/constants.dart';
import 'package:veterinaryapp/login/ui/widgets/responsive_ui.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  late final TextInputType keyboardType;
  late final bool obscureText;
  late final IconData icon;
  late double _width;
  late double _pixelRatio;
  late bool large;
  late bool medium;
  List<TextInputFormatter>? inputFormatters = [];
  CustomTextField(
      {Key? key,
      required this.hint,
      required this.textEditingController,
      required this.keyboardType,
      required this.icon,
      this.obscureText = false,
      this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: large ? 12 : (medium ? 10 : 8),
      child: TextFormField(
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        controller: textEditingController,
        keyboardType: keyboardType,
        cursorColor: Colors.orange[200],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
