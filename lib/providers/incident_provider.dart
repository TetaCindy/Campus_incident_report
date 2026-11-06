import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  IncidentProvider(this._service);

  StreamSubscription<List<Incident>>? _sub;
  String? _uid;
  List<Incident> _all = [];
  bool loading = true;
  bool saving = false;
  String? error;

  String query = '';
  String? categoryFilter;
  String? statusFilter;
  bool mineOnly = false;

  /// Called by ChangeNotifierProxyProvider whenever auth changes.
  void bindUser(String? uid, bool ready) {
    final target = ready ? uid : null;
    if (target == _uid) return;
    _uid = target;
    _sub?.cancel();
    _all = [];
    if (target == null) {
      query = '';
      categoryFilter = null;
      statusFilter = null;
      mineOnly = false;
      return;
    }
    _listen();
  }

  void _listen() {
    loading = true;
    _sub?.cancel();
    _sub = _service.watchAll().listen((list) {
      _all = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
    });
  }

  void retry() {
    if (_uid == null) return;
    error = null;
    _listen();
    notifyListeners();
  }

  @visibleForTesting
  void debugLoad(List<Incident> items, String uid) {
    _all = items;
    _uid = uid;
    loading = false;
  }

  // ---- read side ----
  List<Incident> get mine => _all.where((i) => i.reporterId == _uid).toList();

  List<Incident> get filtered => _all.where((i) {
        if (mineOnly && i.reporterId != _uid) return false;
        if (categoryFilter != null && i.category != categoryFilter) return false;
        if (statusFilter != null && i.status != statusFilter) return false;
        final q = query.trim().toLowerCase();
        return q.isEmpty ||
            i.title.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q);
      }).toList();

  List<Incident> recent({required bool mineOnly, int limit = 3}) =>
      (mineOnly ? mine : _all).take(limit).toList();

  int count({String? status, bool mineOnly = false}) =>
      (mineOnly ? mine : _all).where((i) => status == null || i.status == status).length;

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  // ---- filters ----
  void setQuery(String v) { query = v; notifyListeners(); }
  void setCategory(String? v) { categoryFilter = v; notifyListeners(); }
  void setStatus(String? v) { statusFilter = v; notifyListeners(); }
  void setMineOnly(bool v) { mineOnly = v; notifyListeners(); }

  // ---- write side ----
  Future<bool> _guard(Future<void> Function() fn) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await fn();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> submit(Incident draft, File? photo) => _guard(() => _service.create(draft, photo));

  Future<bool> updateStatus(String id, String status, String? note, {required bool statusChanged}) =>
      _guard(() => _service.updateStatus(id, status, note, statusChanged: statusChanged));

  Future<bool> remove(Incident i) => _guard(() => _service.delete(i));

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
