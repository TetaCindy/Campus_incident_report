import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      if (onAction != null)
        GestureDetector(
          onTap: onAction,
          child: const Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}
