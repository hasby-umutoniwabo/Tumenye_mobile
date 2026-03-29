import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/secrets.dart';

class ImageUploadService {
  static const _cloudName = Secrets.cloudName;
  static const _apiKey = Secrets.cloudinaryApiKey;
  static const _apiSecret = Secrets.cloudinaryApiSecret;

  final _picker = ImagePicker();
  final _db = FirebaseFirestore.instance;

  /// Picks an image from the gallery, uploads it to Cloudinary, and saves
  /// the returned URL to Firestore under `users/{uid}.avatarUrl`.
  ///
  /// Returns the secure URL, or null if the user cancelled.
  Future<String?> pickAndUploadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Cloudinary signed-upload signature: SHA-1 of "timestamp=<ts><secret>"
    final signature = sha1
        .convert(utf8.encode('timestamp=$timestamp$_apiSecret'))
        .toString();

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = _apiKey
      ..fields['timestamp'] = '$timestamp'
      ..fields['signature'] = signature
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'avatar_$uid.jpg',
      ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final url = (jsonDecode(body) as Map<String, dynamic>)['secure_url'] as String;

    await _db.collection('users').doc(uid).update({'avatarUrl': url});

    return url;
  }
}
