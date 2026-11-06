import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final bool showReport;
  final ValueChanged<int> onTab;
  final VoidCallback onReport;
  const AppBottomNav({super.key, required this.index, required this.showReport, required this.onTab, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2))]),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _item(0, Icons.home_rounded, 'Home'),
            _item(1, Icons.description_outlined, 'Reports'),
            if (showReport) _reportButton(),
            _item(2, Icons.person_outline, 'Profile'),
          ]),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final on = index == i;
    final c = on ? AppColors.primary : AppColors.muted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTab(i),
      child: SizedBox(
        width: 64,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: c),
          Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _reportButton() => GestureDetector(
        onTap: onReport,
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
            SizedBox(height: 2),
            Text('Report', style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
        ),
      );
}
