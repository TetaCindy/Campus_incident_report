import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;
  User? firebaseUser;
  AppUser? profile;
  bool initializing = true;
  bool busy = false;
  bool _verifiedReady = false;
  String? error;

  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_sync);
  }

  bool get loggedIn => firebaseUser != null;

  /// True only when the email is verified AND the ID token already carries that claim,
  /// otherwise Firestore rules would still reject requests right after verifying.
  bool get verified => _verifiedReady;
  bool get isStaff => profile?.isStaff ?? false;
  String get displayName => profile?.name ?? firebaseUser?.displayName ?? '';
  String get email => firebaseUser?.email ?? '';

  Future<void> _sync(User? u) async {
    firebaseUser = u;
    _verifiedReady = false;
    try {
      if (u == null) {
        profile = null;
      } else {
        if (u.emailVerified) {
          var r = await u.getIdTokenResult();
          if (r.claims?['email_verified'] != true) r = await u.getIdTokenResult(true);
          _verifiedReady = r.claims?['email_verified'] == true;
        }
        profile = await _service.loadProfile(u.uid);
      }
    } catch (e) {
      error = e.toString();
    }
    initializing = false;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() fn) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await fn();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? e.code;
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> signIn(String email, String pw) => _run(() => _service.signIn(email, pw));

  Future<bool> register(String name, String email, String pw) => _run(() async {
        final uid = await _service.register(name, email, pw);
        // The auth listener fires before the profile document exists, so load it again.
        profile = await _service.loadProfile(uid);
      });

  Future<bool> resend() => _run(_service.resendVerification);

  Future<void> checkVerified() async {
    await _service.reloadUser();
    await _sync(_service.currentUser);
  }

  /// Staff use this to see who filed an anonymous report.
  Future<String?> lookupName(String uid) async => (await _service.loadProfile(uid))?.name;

  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
