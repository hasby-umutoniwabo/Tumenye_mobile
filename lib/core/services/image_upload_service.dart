import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _db = FirebaseFirestore.instance;

  /// Picks an image from the gallery, uploads it to Firebase Storage at
  /// `avatars/{uid}.jpg`, saves the download URL to Firestore, and updates
  /// Firebase Auth's photoURL.
  ///
  /// Returns the new download URL, or null if the user cancelled.
  /// Throws on upload / Firestore errors.
  Future<String?> pickAndUploadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    // Pick from gallery — resize to max 512×512 and compress to 85%
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null; // user cancelled

    final file = File(picked.path);
    final ref = _storage.ref().child('avatars/$uid.jpg');

    // Upload with content-type so browsers/CDNs serve it correctly
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();

    // Persist URL in both Firestore and Firebase Auth profile
    await Future.wait([
      _db.collection('users').doc(uid).update({'avatarUrl': url}),
      FirebaseAuth.instance.currentUser!.updatePhotoURL(url),
    ]);

    return url;
  }
}
