import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportBanner extends StatelessWidget {
  final VoidCallback onTap;
  const ReportBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF9F86FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(children: [
        Positioned(right: 0, bottom: 40, child: Icon(Icons.apartment, size: 90, color: Colors.white.withAlpha(60))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('See an issue\non campus?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, height: 1.2)),
          const SizedBox(height: 6),
          const Text('Report it and help improve\nour learning environment.', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Icon(Icons.add, size: 16, color: Colors.white)),
                SizedBox(width: 10),
                Expanded(child: Text('Report an Issue', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
                Icon(Icons.chevron_right, color: AppColors.primary),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}
