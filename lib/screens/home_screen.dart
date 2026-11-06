import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/incident_card.dart';
import '../widgets/report_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import '../widgets/user_avatar.dart';
import 'incident_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  final VoidCallback onReport;
  const HomeScreen({super.key, required this.onSeeAll, required this.onReport});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final staff = auth.isStaff;
    final mine = !staff;
    final first = auth.displayName.trim().isEmpty ? 'there' : auth.displayName.trim().split(' ').first;
    final recent = p.recent(mineOnly: mine);

    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, $first 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(staff ? 'Review reports and keep campus running.' : 'Help make our campus safer.',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(staff ? 'Update statuses as issues are resolved.' : 'Report issues and track their resolution.',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ]),
          ),
          UserAvatar(auth.displayName, radius: 24),
        ]),
        const SizedBox(height: 18),
        if (!staff) ...[ReportBanner(onTap: onReport), const SizedBox(height: 22)],
        SectionHeader('Report Summary', onAction: onSeeAll),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: StatTile(icon: Icons.description_outlined, color: AppColors.primary, value: p.count(mineOnly: mine), label: staff ? 'All Reports' : 'My Reports')),
          const SizedBox(width: 8),
          Expanded(child: StatTile(icon: Icons.schedule, color: AppColors.inProgress, value: p.count(status: 'In Progress', mineOnly: mine), label: 'In Progress')),
          const SizedBox(width: 8),
          Expanded(child: StatTile(icon: Icons.check_circle_outline, color: AppColors.resolved, value: p.count(status: 'Resolved', mineOnly: mine), label: 'Resolved')),
          const SizedBox(width: 8),
          Expanded(child: StatTile(icon: Icons.error_outline, color: AppColors.danger, value: p.count(status: 'Submitted', mineOnly: mine), label: 'Submitted')),
        ]),
        const SizedBox(height: 22),
        SectionHeader('Recent Reports', onAction: onSeeAll),
        const SizedBox(height: 10),
        if (p.loading)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (p.error != null)
          Column(children: [
            Text('Could not load reports.\n${p.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger)),
            TextButton(onPressed: p.retry, child: const Text('Retry')),
          ])
        else if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(staff ? 'No reports yet.' : 'No reports yet. Tap "Report" to file your first one.',
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          )
        else
          ...recent.map((i) => IncidentCard(
                incident: i,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: i.id))),
              )),
      ]),
    );
  }
}
