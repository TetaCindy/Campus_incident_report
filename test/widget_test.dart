import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/widgets/status_chip.dart';
import 'package:campus_incident_app/widgets/status_timeline.dart';

Incident _incident(String status) {
  final t = DateTime(2026, 10, 15, 10, 24);
  return Incident(
    id: '1', title: 'Water shortage', description: 'No water since morning', category: 'Water',
    location: 'Student Residence', status: status, reporterId: 'u1', reporterName: 'Amina',
    anonymous: false, createdAt: t, updatedAt: t,
    history: [StatusEntry('Submitted', t), if (status != 'Submitted') StatusEntry('In Progress', t.add(const Duration(hours: 28)))],
  );
}

void main() {
  testWidgets('StatusChip shows its label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StatusChip('Resolved'))));
    expect(find.text('Resolved'), findsOneWidget);
  });

  testWidgets('StatusTimeline shows all three steps', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatusTimeline(_incident('In Progress')))));
    for (final s in statuses) {
      expect(find.text(s), findsOneWidget);
    }
    expect(find.text('—'), findsOneWidget); // Resolved not reached yet
  });
}
