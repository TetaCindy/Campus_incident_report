import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/incident.dart';

void main() {
  final created = DateTime(2026, 10, 15, 10, 24);
  final progress = DateTime(2026, 10, 16, 14, 30);

  Incident make(String status, List<StatusEntry> h) => Incident(
        id: '1', title: 't', description: 'd', category: 'Water', location: 'Block A', status: status,
        reporterId: 'u', reporterName: 'n', anonymous: false, createdAt: created, updatedAt: created, history: h);

  test('stepIndex follows status order', () {
    expect(make('Submitted', []).stepIndex, 0);
    expect(make('In Progress', []).stepIndex, 1);
    expect(make('Resolved', []).stepIndex, 2);
  });

  test('statusTime returns when each step was reached', () {
    final i = make('In Progress', [StatusEntry('Submitted', created), StatusEntry('In Progress', progress)]);
    expect(i.statusTime('In Progress'), progress);
    expect(i.statusTime('Resolved'), isNull);
    expect(make('Submitted', []).statusTime('Submitted'), created); // falls back to createdAt
  });

  test('anonymous reports do not store the reporter name', () {
    final anon = Incident(
      id: '', title: 't', description: 'd', category: 'Water', location: 'Block A', status: 'Submitted',
      reporterId: 'u', reporterName: 'Amina Hassan', anonymous: true, createdAt: created, updatedAt: created);
    expect(anon.toCreateMap()['reporterName'], 'Anonymous');
  });
}
