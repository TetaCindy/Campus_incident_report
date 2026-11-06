import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_tile.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final staff = auth.isStaff;
    final mine = !staff;

    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Row(children: [
            UserAvatar(auth.displayName, radius: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 2),
                Text(auth.email, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: Text(staff ? 'Staff' : 'Student', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: StatTile(icon: Icons.description_outlined, color: AppColors.primary, value: p.count(mineOnly: mine), label: staff ? 'All Reports' : 'Total Reports')),
          const SizedBox(width: 8),
          Expanded(child: StatTile(icon: Icons.schedule, color: AppColors.inProgress, value: p.count(status: 'In Progress', mineOnly: mine), label: 'In Progress')),
          const SizedBox(width: 8),
          Expanded(child: StatTile(icon: Icons.check_circle_outline, color: AppColors.resolved, value: p.count(status: 'Resolved', mineOnly: mine), label: 'Resolved')),
        ]),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: auth.signOut,
          icon: const Icon(Icons.logout, color: AppColors.danger),
          label: const Text('Log out', style: TextStyle(color: AppColors.danger)),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), side: const BorderSide(color: AppColors.danger)),
        ),
      ]),
    );
  }
}
