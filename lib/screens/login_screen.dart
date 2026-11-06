import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.shield_outlined, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                const Text('Campus Incident Reporter', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Help make our campus safer.', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'ALU email',
                  hint: 'name@alustudent.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => AuthService.isAluEmail(v ?? '') ? null : 'Enter a valid ALU email',
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  hint: 'Your password',
                  controller: _pw,
                  obscure: true,
                  validator: (v) => (v ?? '').length >= 6 ? null : 'At least 6 characters',
                ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(auth.error!, style: const TextStyle(color: AppColors.danger)),
                  ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Log in',
                  loading: auth.busy,
                  onPressed: () {
                    if (_form.currentState!.validate()) auth.signIn(_email.text, _pw.text);
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Create an account'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
