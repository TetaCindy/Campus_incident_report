import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import 'cloudinary_service.dart';

class IncidentService {
  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore.instance.collection('incidents');
  // Photos go to Cloudinary; only the returned URL is stored in Firestore.
  final CloudinaryService _images = CloudinaryService();

  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  Future<void> create(Incident draft, File? photo) async {
    final doc = _col.doc();
    String? url;
    if (photo != null) {
      url = await _images.uploadImage(photo, publicId: '${draft.reporterId}_${doc.id}');
    }
    final map = draft.toCreateMap()..['photoUrl'] = url;
    await doc.set(map);
  }

  /// Staff only (enforced by Firestore rules). History is appended only when the status changes.
  Future<void> updateStatus(String id, String status, String? note, {required bool statusChanged}) {
    final data = <String, dynamic>{
      'status': status,
      'staffNote': note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (statusChanged) {
      data['statusHistory'] = FieldValue.arrayUnion([
        {'status': status, 'at': Timestamp.now()}
      ]);
    }
    return _col.doc(id).update(data);
  }

  /// Deletes the report. Unsigned Cloudinary uploads cannot be deleted from the app,
  /// so the image file stays in Cloudinary (remove it from their Media Library if needed).
  Future<void> delete(Incident i) => _col.doc(i.id).delete();
}
