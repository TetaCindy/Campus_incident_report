import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/providers/incident_provider.dart';
import 'package:campus_incident_app/services/incident_service.dart';

Incident _i(String id, String title, String category, String status, String uid, {String location = 'Block A'}) {
  final t = DateTime(2026, 10, 1);
  return Incident(
    id: id, title: title, description: 'desc $title', category: category, location: location,
    status: status, reporterId: uid, reporterName: 'N', anonymous: false, createdAt: t, updatedAt: t,
  );
}

void main() {
  late IncidentProvider p;

  setUp(() {
    p = IncidentProvider(IncidentService());
    p.debugLoad([
      _i('1', 'Leaking tap', 'Water', 'Submitted', 'me'),
      _i('2', 'Broken projector', 'Facilities', 'In Progress', 'other', location: 'Block B'),
      _i('3', 'Overflowing bin', 'Sanitation', 'Resolved', 'me', location: 'Cafeteria'),
    ], 'me');
  });

  test('no filters returns everything', () => expect(p.filtered.length, 3));

  test('filters by category', () {
    p.setCategory('Water');
    expect(p.filtered.map((e) => e.id), ['1']);
  });

  test('filters by status', () {
    p.setStatus('Resolved');
    expect(p.filtered.map((e) => e.id), ['3']);
  });

  test('search matches title and location, case-insensitive', () {
    p.setQuery('PROJECTOR');
    expect(p.filtered.map((e) => e.id), ['2']);
    p.setQuery('cafeteria');
    expect(p.filtered.map((e) => e.id), ['3']);
  });

  test('"my reports" only returns the signed-in user\'s reports', () {
    p.setMineOnly(true);
    expect(p.filtered.map((e) => e.id).toSet(), {'1', '3'});
  });

  test('combined filters narrow results', () {
    p.setMineOnly(true);
    p.setStatus('Submitted');
    expect(p.filtered.map((e) => e.id), ['1']);
  });

  test('counts for summary tiles', () {
    expect(p.count(), 3);
    expect(p.count(mineOnly: true), 2);
    expect(p.count(status: 'In Progress'), 1);
    expect(p.count(status: 'In Progress', mineOnly: true), 0);
  });

  test('byId finds incidents', () {
    expect(p.byId('2')?.title, 'Broken projector');
    expect(p.byId('zzz'), isNull);
  });
}
