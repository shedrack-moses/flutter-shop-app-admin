import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText, label;
  final TextInputType? keyboardType;
  String? Function(String?)? validator;
  Color? fillColor;
  int? maxLines;

  CustomTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.label,
      this.keyboardType,
      this.fillColor,
      this.validator,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            // borderSide: BorderSide.none,
            ),
        hintText: hintText,
        label: Text(label),
        fillColor: fillColor ?? Colors.deepPurple.shade50,
        filled: true,
      ),
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
    );
  }
}
