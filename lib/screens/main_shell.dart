import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'submit_incident_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;
    return Scaffold(
      body: IndexedStack(index: _tab, children: [
        HomeScreen(onSeeAll: () => setState(() => _tab = 1), onReport: _openReport),
        const ReportsScreen(),
        const ProfileScreen(),
      ]),
      bottomNavigationBar: AppBottomNav(
        index: _tab,
        showReport: !isStaff, // staff review reports; they don't file them
        onTab: (i) => setState(() => _tab = i),
        onReport: _openReport,
      ),
    );
  }

  void _openReport() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitIncidentScreen()));
}
