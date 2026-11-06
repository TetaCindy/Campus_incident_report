import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Uploads report photos to Cloudinary using an UNSIGNED upload preset.
///
/// Fill in the two values below from your Cloudinary dashboard:
///   cloudName    -> "Cloud name" (View API Keys page)
///   uploadPreset -> Settings > Upload > Upload presets (Signing mode: Unsigned)
class CloudinaryService {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET';

  /// Uploads [photo] and returns its HTTPS URL. Throws a readable String on failure.
  Future<String> uploadImage(File photo, {String? publicId}) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'incidents';
    if (publicId != null) req.fields['public_id'] = publicId;
    req.files.add(await http.MultipartFile.fromPath('file', photo.path));

    final streamed = await req.send().timeout(const Duration(seconds: 60));
    final body = await streamed.stream.bytesToString();
    Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw 'Photo upload failed (unexpected response).';
    }
    if (streamed.statusCode != 200) {
      final msg = (json['error'] as Map?)?['message'] ?? 'status ${streamed.statusCode}';
      throw 'Photo upload failed: $msg';
    }
    final url = json['secure_url'] as String?;
    if (url == null) throw 'Photo upload failed: no URL returned.';
    return url;
  }
}
