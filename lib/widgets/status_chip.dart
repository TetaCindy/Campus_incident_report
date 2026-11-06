import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Color statusColor(String s) => switch (s) {
      'Submitted' => AppColors.submitted,
      'In Progress' => AppColors.inProgress,
      'Resolved' => AppColors.resolved,
      _ => AppColors.muted,
    };

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withAlpha(36), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}
