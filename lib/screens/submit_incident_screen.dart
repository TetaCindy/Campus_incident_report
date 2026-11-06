import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_selector.dart';
import '../widgets/primary_button.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});
  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _detail = TextEditingController();
  String _category = categories.first;
  String? _area;
  bool _anonymous = false;
  File? _photo;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await ImagePicker().pickImage(source: src, maxWidth: 1280, imageQuality: 80);
      if (x != null) setState(() => _photo = File(x.path));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open picker: $e')));
    }
  }

  void _photoSheet() => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Take a photo'), onTap: () { Navigator.pop(context); _pick(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_outlined), title: const Text('Choose from gallery'), onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); }),
          ]),
        ),
      );

  Future<String?> _areaSheet() => showModalBottomSheet<String>(
        context: context,
        builder: (_) => SafeArea(
          child: ListView(shrinkWrap: true, children: [
            for (final a in campusLocations) ListTile(leading: const Icon(Icons.place_outlined), title: Text(a), onTap: () => Navigator.pop(context, a)),
          ]),
        ),
      );

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final prov = context.read<IncidentProvider>();
    final detail = _detail.text.trim();
    final now = DateTime.now();
    final draft = Incident(
      id: '',
      title: _title.text.trim(),
      description: _desc.text.trim(),
      category: _category,
      location: detail.isEmpty ? _area! : '$_area — $detail',
      status: 'Submitted',
      reporterId: auth.firebaseUser!.uid,
      reporterName: auth.displayName,
      anonymous: _anonymous,
      createdAt: now,
      updatedAt: now,
    );
    final ok = await prov.submit(draft, _photo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Report submitted' : 'Failed: ${prov.error}')));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<IncidentProvider>().saving;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident'), centerTitle: true, backgroundColor: AppColors.background, elevation: 0),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Select a category', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          CategorySelector(selected: _category, onChanged: (c) => setState(() => _category = c)),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Title',
            hint: 'Briefly describe the issue...',
            controller: _title,
            validator: (v) => (v ?? '').trim().length < 4 ? 'Enter at least 4 characters' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Description',
            hint: 'Provide more details: what happened, when, impact...',
            controller: _desc,
            maxLines: 4,
            validator: (v) => (v ?? '').trim().length < 10 ? 'Describe the issue (at least 10 characters)' : null,
          ),
          const SizedBox(height: 14),
          const Text('Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          FormField<String>(
            validator: (_) => _area == null ? 'Choose a location' : null,
            builder: (state) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () async {
                  final a = await _areaSheet();
                  if (a != null) {
                    setState(() => _area = a);
                    state.didChange(a);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: state.hasError ? AppColors.danger : AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.place_outlined, color: AppColors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_area ?? 'Select location', style: TextStyle(color: _area == null ? AppColors.muted : AppColors.text))),
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
                  ]),
                ),
              ),
              if (state.hasError)
                Padding(padding: const EdgeInsets.only(top: 6, left: 12), child: Text(state.errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
            ]),
          ),
          const SizedBox(height: 10),
          AppTextField(hint: 'Room or detail, e.g. Room 204 (optional)', controller: _detail),
          const SizedBox(height: 14),
          const Text('Add a photo (optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          if (_photo == null)
            GestureDetector(
              onTap: _photoSheet,
              child: Container(
                height: 90,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.image_outlined, color: AppColors.muted),
                  SizedBox(height: 4),
                  Text('Tap to add photo', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ),
            )
          else
            Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_photo!, height: 180, width: double.infinity, fit: BoxFit.cover)),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _photo = null),
                  child: const CircleAvatar(radius: 14, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 16, color: Colors.white)),
                ),
              ),
            ]),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _anonymous,
            onChanged: (v) => setState(() => _anonymous = v),
            title: const Text('Report anonymously', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Other students never see your name. Campus staff can still see who filed it.', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Submit Report', loading: saving, onPressed: _submit),
        ]),
      ),
    );
  }
}
