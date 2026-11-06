import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;
  const StatTile({super.key, required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withAlpha(22), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.text)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted), textAlign: TextAlign.center),
      ]),
    );
  }
}
