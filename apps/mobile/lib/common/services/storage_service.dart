import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/network/api_client.dart';

class StorageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image XFile (works on Web, Mobile, Desktop)
  static Future<XFile?> pickImageXFile({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('[StorageService] Error picking image: $e');
    }
    return null;
  }

  /// Pick an image from gallery or camera as File (Mobile only fallback)
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await pickImageXFile(source: source);
      if (pickedFile != null) {
        if (!kIsWeb) {
          return File(pickedFile.path);
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Error picking image: $e');
    }
    return null;
  }

  /// Upload raw bytes directly (safe on Web & all platforms)
  static Future<String?> uploadBytes({
    required String bucket,
    required Uint8List bytes,
    required String fileName,
    required String remotePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'bucket': bucket,
        'path': remotePath,
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await ApiClient.post('/files/upload', data: formData);
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['fileUrl']?.toString();
        }
        if (resData is Map) {
          return resData['fileUrl']?.toString() ?? resData['url']?.toString();
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Error uploading bytes: $e');
    }
    return null;
  }

  /// Upload file via multipart request through backend S3 gateway
  static Future<String?> uploadFile({
    required String bucket,
    required File file,
    required String remotePath,
  }) async {
    try {
      final fileName = p.basename(file.path);
      final bytes = await file.readAsBytes();
      return await uploadBytes(
        bucket: bucket,
        bytes: bytes,
        fileName: fileName,
        remotePath: remotePath,
      );
    } catch (e) {
      debugPrint('[StorageService] Error uploading file: $e');
    }
    return null;
  }

  /// Upload profile picture helper (bytes)
  static Future<String?> uploadProfilePhotoBytes(String userId, Uint8List bytes, {String extension = '.jpg'}) async {
    final remotePath = '$userId/avatar$extension';
    return await uploadBytes(
      bucket: 'avatars',
      bytes: bytes,
      fileName: 'avatar$extension',
      remotePath: remotePath,
    );
  }

  /// Upload cover photo helper (bytes)
  static Future<String?> uploadCoverPhotoBytes(String userId, Uint8List bytes, {String extension = '.jpg'}) async {
    final remotePath = '$userId/cover$extension';
    return await uploadBytes(
      bucket: 'covers',
      bytes: bytes,
      fileName: 'cover$extension',
      remotePath: remotePath,
    );
  }

  /// Upload profile picture helper (file)
  static Future<String?> uploadProfilePhoto(String userId, File file) async {
    final extension = p.extension(file.path);
    final remotePath = '$userId/avatar$extension';
    return await uploadFile(bucket: 'avatars', file: file, remotePath: remotePath);
  }

  /// Upload cover photo helper (file)
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
