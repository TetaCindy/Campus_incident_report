import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account'), backgroundColor: AppColors.background, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(children: [
            AppTextField(
              label: 'Full name',
              hint: 'Your full name',
              controller: _name,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'ALU email',
              hint: 'name@alustudent.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => AuthService.isAluEmail(v ?? '') ? null : 'Use your @alustudent.com or @alueducation.com email',
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Students: @alustudent.com   Campus staff: @alueducation.com (staff access)',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Password',
              hint: 'At least 6 characters',
              controller: _pw,
              obscure: true,
              validator: (v) => (v ?? '').length >= 6 ? null : 'At least 6 characters',
            ),
            if (auth.error != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(auth.error!, style: const TextStyle(color: AppColors.danger))),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Register',
              loading: auth.busy,
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                final ok = await auth.register(_name.text.trim(), _email.text, _pw.text);
                if (ok && context.mounted) Navigator.pop(context);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
