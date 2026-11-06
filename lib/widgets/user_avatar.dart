import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const UserAvatar(this.name, {super.key, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty ? '?' : parts.take(2).map((p) => p[0].toUpperCase()).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(initials, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: radius * 0.75)),
    );
  }
}
