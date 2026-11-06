import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_text_field.dart';
import '../widgets/incident_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_timeline.dart';

class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});
  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  String? _status;
  final _note = TextEditingController();
  bool _init = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _delete(Incident i) async {
    final prov = context.read<IncidentProvider>();
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (sure != true) return;
    final ok = await prov.remove(i);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${prov.error}')));
    }
  }

  Future<void> _save(Incident i) async {
    final prov = context.read<IncidentProvider>();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final changed = _status != i.status;
    if (!changed && note == i.staffNote) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to update')));
      return;
    }
    final ok = await prov.updateStatus(i.id, _status!, note, statusChanged: changed);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Status updated' : 'Update failed: ${prov.error}')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prov = context.watch<IncidentProvider>();
    final i = prov.byId(widget.incidentId);
    if (i == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This report no longer exists.')));
    }
    final staff = auth.isStaff;
    final owner = i.reporterId == auth.firebaseUser?.uid;
    final canDelete = staff || (owner && i.status == 'Submitted');
    if (!_init) {
      _status = i.status;
      _note.text = i.staffNote ?? '';
      _init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          if (canDelete)
            PopupMenuButton<String>(
              onSelected: (_) => _delete(i),
              itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete report'))],
            ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IncidentThumb(i, size: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text('${i.category} • ${i.location}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 6),
                StatusChip(i.status),
                const SizedBox(height: 10),
                _meta(Icons.calendar_today_outlined, 'Submitted on ${fullDate(i.createdAt)}'),
                const SizedBox(height: 4),
                _ReporterLine(incident: i, showReal: staff, isOwner: owner),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Status Timeline', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            StatusTimeline(i),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(i.description, style: const TextStyle(height: 1.4)),
          ]),
        ),
        if ((i.staffNote ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Note from campus staff', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(i.staffNote!),
            ]),
          ),
        ],
        if (i.photoUrl != null) ...[
          const SizedBox(height: 16),
          const Text('Attached Photo', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              i.photoUrl!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) => p == null ? child : const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
              errorBuilder: (_, __, ___) => const SizedBox(height: 80, child: Center(child: Text('Photo unavailable'))),
            ),
          ),
        ],
        // Staff-only controls. Also enforced by Firestore security rules.
        if (staff) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Update status (staff)', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                for (final s in statuses)
                  ChoiceChip(
                    label: Text(s),
                    selected: _status == s,
                    selectedColor: statusColor(s).withAlpha(60),
                    onSelected: (_) => setState(() => _status = s),
                  ),
              ]),
              const SizedBox(height: 12),
              AppTextField(hint: 'Note for the student (optional)', controller: _note, maxLines: 2),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Save update', loading: prov.saving, onPressed: () => _save(i)),
            ]),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.muted))),
      ]);
}

class _ReporterLine extends StatelessWidget {
  final Incident incident;
  final bool showReal;
  final bool isOwner;
  const _ReporterLine({required this.incident, required this.showReal, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    Widget line(String t) => Row(children: [
          const Icon(Icons.person_outline, size: 13, color: AppColors.muted),
          const SizedBox(width: 6),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.muted))),
        ]);
    // Staff can resolve the real identity of an anonymous report; peers cannot.
    if (incident.anonymous && showReal) {
      return FutureBuilder<String?>(
        future: context.read<AuthProvider>().lookupName(incident.reporterId),
        builder: (_, s) => line('Reported by Anonymous${s.data == null ? '' : ' (${s.data}, visible to staff only)'}'),
      );
    }
    return line('Reported by ${incident.anonymous && isOwner ? 'You (anonymous)' : incident.reporterName}');
  }
}
