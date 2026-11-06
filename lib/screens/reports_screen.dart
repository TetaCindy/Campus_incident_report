import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<AuthProvider>().isStaff;
    final p = context.watch<IncidentProvider>();
    final items = p.filtered;

    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(staff ? 'All Reports' : 'Reports', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppTextField(
            hint: 'Search title, description or location',
            prefixIcon: Icons.search,
            onChanged: p.setQuery,
          ),
        ),
        if (!staff)
          _row([
            _pill('All campus', !p.mineOnly, () => p.setMineOnly(false)),
            _pill('My reports', p.mineOnly, () => p.setMineOnly(true)),
          ]),
        _row([
          _pill('All', p.statusFilter == null, () => p.setStatus(null)),
          ...statuses.map((s) => _pill(s, p.statusFilter == s, () => p.setStatus(p.statusFilter == s ? null : s))),
        ]),
        _row(categories
            .map((c) => _pill(c, p.categoryFilter == c, () => p.setCategory(p.categoryFilter == c ? null : c), outlined: true))
            .toList()),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text('${items.length} report${items.length == 1 ? '' : 's'}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
        Expanded(
          child: p.loading
              ? const Center(child: CircularProgressIndicator())
              : p.error != null
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Could not load reports.\n${p.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger)),
                        TextButton(onPressed: p.retry, child: const Text('Retry')),
                      ]),
                    )
                  : items.isEmpty
                      ? const Center(child: Text('No reports match your filters.', style: TextStyle(color: AppColors.muted)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          itemBuilder: (_, i) => IncidentCard(
                            incident: items[i],
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: items[i].id))),
                          ),
                        ),
        ),
      ]),
    );
  }

  Widget _row(List<Widget> children) => SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: children),
      );

  Widget _pill(String label, bool on, VoidCallback onTap, {bool outlined = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppColors.primary : (outlined ? Colors.white : AppColors.primaryLight),
              borderRadius: BorderRadius.circular(20),
              border: outlined && !on ? Border.all(color: AppColors.border) : null,
            ),
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? Colors.white : (outlined ? AppColors.text : AppColors.primary))),
          ),
        ),
      );
}
