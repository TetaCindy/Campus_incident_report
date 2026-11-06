import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/services/auth_service.dart';

void main() {
  test('accepts ALU student and staff emails', () {
    expect(AuthService.isAluEmail('teta@alustudent.com'), isTrue);
    expect(AuthService.isAluEmail('Staff.Name@alueducation.com'), isTrue);
    expect(AuthService.isAluEmail('  teta@alustudent.com  '), isTrue);
  });

  test('rejects non-ALU and malformed emails', () {
    expect(AuthService.isAluEmail('someone@gmail.com'), isFalse);
    expect(AuthService.isAluEmail('teta@alustudent.com.evil.com'), isFalse);
    expect(AuthService.isAluEmail('@alustudent.com'), isFalse);
    expect(AuthService.isAluEmail(''), isFalse);
  });

  test('only @alueducation.com addresses count as staff', () {
    expect(AuthService.isStaffEmail('lecturer@alueducation.com'), isTrue);
    expect(AuthService.isStaffEmail('Lecturer@AluEducation.com'), isTrue);
    expect(AuthService.isStaffEmail('teta@alustudent.com'), isFalse);
    expect(AuthService.isStaffEmail('x@alueducation.com.evil.com'), isFalse);
    expect(AuthService.isStaffEmail('someone@gmail.com'), isFalse);
  });
}
