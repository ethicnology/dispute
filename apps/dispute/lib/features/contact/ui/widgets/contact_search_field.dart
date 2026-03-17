import 'package:flutter/material.dart';

class ContactSearchField extends StatelessWidget {
  const ContactSearchField({
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.hint = '',
    this.onChanged,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      suffixIcon: suffixIcon,
    ),
    onSubmitted: onSubmitted,
    onChanged: onChanged,
  );
}
