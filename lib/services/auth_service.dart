import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Only ALU email domains may register (also enforced in Firestore/Storage rules).
/// The domain also decides the role: students use alustudent.com, staff use alueducation.com.
const studentDomain = 'alustudent.com';
const staffDomain = 'alueducation.com';
const allowedDomains = [studentDomain, staffDomain];

class AuthService {
  // Getters (not fields) so the class can be constructed in tests without Firebase.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  static bool isAluEmail(String email) {
    final e = email.trim().toLowerCase();
    return allowedDomains.any((d) => e.endsWith('@$d')) && e.indexOf('@') > 0;
  }

  static bool isStaffEmail(String email) =>
      isAluEmail(email) && email.trim().toLowerCase().endsWith('@$staffDomain');

  Future<String> register(String name, String email, String password) async {
    if (!isAluEmail(email)) throw 'Use your ALU email address.';
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await cred.user!.updateDisplayName(name);
    // Role follows the verified-domain convention. Firestore rules re-check this on the server,
    // so a student address can never create a staff profile. Roles can still be changed in the Console.
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email.trim().toLowerCase(),
      'role': isStaffEmail(email) ? 'staff' : 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await cred.user!.sendEmailVerification();
    return cred.user!.uid;
  }

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> resendVerification() async => _auth.currentUser?.sendEmailVerification();
  Future<void> reloadUser() async => _auth.currentUser?.reload();
  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> loadProfile(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    return d.exists ? AppUser.fromMap(uid, d.data()!) : null;
  }
}
