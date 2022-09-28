import 'package:flutter/material.dart';

textFieldDecoration(l) {
  return InputDecoration(
    labelText: l,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class TextFieldWidget extends StatefulWidget {
  final int maxLines;
  final String label;
  final TextEditingController controller;
  const TextFieldWidget({
    Key? key,
    this.maxLines = 1,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: widget.maxLines,
          ),
        ],
      );
}
