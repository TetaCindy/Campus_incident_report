import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text('Verify your ALU email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('We sent a link to ${auth.email}. Open it, then tap the button below.',
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            if (auth.error != null)
              Padding(padding: const EdgeInsets.only(top: 8), child: Text(auth.error!, style: const TextStyle(color: AppColors.danger))),
            const SizedBox(height: 20),
            PrimaryButton(label: "I've verified", loading: auth.busy, onPressed: auth.checkVerified),
            TextButton(onPressed: auth.resend, child: const Text('Resend email')),
            TextButton(onPressed: auth.signOut, child: const Text('Log out')),
          ]),
        ),
      ),
    );
  }
}
