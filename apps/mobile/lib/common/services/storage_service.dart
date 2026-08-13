import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  /// Upload a file to a specific Supabase storage bucket
  static Future<String?> uploadFile({
    required String bucket,
    required File file,
    required String remotePath,
  }) async {
    try {
      // Upload the file
      await SupabaseService.client.storage.from(bucket).upload(
            remotePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      return SupabaseService.getPublicUrl(bucket, remotePath);
    } catch (e) {
      print('Error uploading file to storage bucket $bucket: $e');
      return null;
    }
  }

  /// Upload profile picture helper
  static Future<String?> uploadProfilePhoto(String userId, File file) async {
    final extension = p.extension(file.path);
    final remotePath = '$userId/avatar$extension';
    return await uploadFile(bucket: 'avatars', file: file, remotePath: remotePath);
  }

  /// Upload cover photo helper
  static Future<String?> uploadCoverPhoto(String userId, File file) async {
    final extension = p.extension(file.path);
    final remotePath = '$userId/cover$extension';
    return await uploadFile(bucket: 'covers', file: file, remotePath: remotePath);
  }

  /// Upload post image helper
  static Future<String?> uploadPostImage(String userId, File file) async {
    final extension = p.extension(file.path);
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final remotePath = '$userId/$uniqueId$extension';
    return await uploadFile(bucket: 'post-images', file: file, remotePath: remotePath);
  }
}
