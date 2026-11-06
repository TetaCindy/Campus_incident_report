enum UserRole { student, staff }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  const AppUser({required this.uid, required this.name, required this.email, required this.role});

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        role: m['role'] == 'staff' ? UserRole.staff : UserRole.student,
      );
}
