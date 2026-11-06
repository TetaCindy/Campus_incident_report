import 'package:cloud_firestore/cloud_firestore.dart';

const categories = ['Facilities', 'Water', 'Electricity', 'Furniture', 'Safety', 'Sanitation'];
const statuses = ['Submitted', 'In Progress', 'Resolved'];
const campusLocations = [
  'Block A',
  'Block B',
  'Block C',
  'Student Residence',
  'Cafeteria',
  'Library',
  'Sports Field',
  'Parking',
  'Other',
];

/// One entry in an incident's status history (drives the timeline).
class StatusEntry {
  final String status;
  final DateTime at;
  const StatusEntry(this.status, this.at);

  factory StatusEntry.fromMap(Map<String, dynamic> m) =>
      StatusEntry(m['status'] ?? '', (m['at'] as Timestamp?)?.toDate() ?? DateTime.now());
}

class Incident {
  final String id, title, description, category, location, status, reporterId, reporterName;
  final String? photoUrl, staffNote;
  final bool anonymous;
  final DateTime createdAt, updatedAt;
  final List<StatusEntry> history;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.anonymous,
    required this.createdAt,
    required this.updatedAt,
    this.history = const [],
    this.photoUrl,
    this.staffNote,
  });

  int get stepIndex => statuses.indexOf(status).clamp(0, statuses.length - 1);

  /// Most recent time the incident entered [s], or null if it never did.
  DateTime? statusTime(String s) {
    for (final e in history.reversed) {
      if (e.status == s) return e.at;
    }
    return s == 'Submitted' ? createdAt : null;
  }

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    DateTime t(dynamic v) => (v as Timestamp?)?.toDate() ?? DateTime.now();
    final rawHistory = (m['statusHistory'] as List?) ?? const [];
    return Incident(
      id: d.id,
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      category: m['category'] ?? categories.first,
      location: m['location'] ?? '',
      status: m['status'] ?? statuses.first,
      reporterId: m['reporterId'] ?? '',
      reporterName: m['reporterName'] ?? '',
      anonymous: m['anonymous'] ?? false,
      photoUrl: m['photoUrl'],
      staffNote: m['staffNote'],
      createdAt: t(m['createdAt']),
      updatedAt: t(m['updatedAt']),
      history: rawHistory.map((e) => StatusEntry.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'status': 'Submitted',
        'reporterId': reporterId,
        // Anonymous reports never store the reporter's name in the shared document.
        'reporterName': anonymous ? 'Anonymous' : reporterName,
        'anonymous': anonymous,
        'photoUrl': photoUrl,
        'staffNote': null,
        'statusHistory': [
          {'status': 'Submitted', 'at': Timestamp.now()}
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
