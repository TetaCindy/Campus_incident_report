import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) ...[
        Text(label!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
      ],
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: border(AppColors.border),
          focusedBorder: border(AppColors.primary),
          errorBorder: border(AppColors.danger),
          focusedErrorBorder: border(AppColors.danger),
        ),
      ),
    ]);
  }
}
