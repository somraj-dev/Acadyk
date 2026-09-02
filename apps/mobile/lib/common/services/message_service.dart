import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/websocket_service.dart';

class MessageService {
  /// Fetch all conversations for the current user
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await ApiClient.get('/conversations');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) {
            return List<Map<String, dynamic>>.from(payload);
          }
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            return List<Map<String, dynamic>>.from(payload['content']);
          }
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error fetching conversations: $e');
    }
    return [];
  }

  /// Fetch messages for a specific conversation
  static Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await ApiClient.get('/conversations/$conversationId/messages');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            return List<Map<String, dynamic>>.from(payload['content']);
          }
          if (payload is List) {
            return List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
    return [];
  }

  /// Send a message to a conversation (via REST API + broadcasted via WebSocket)
  static Future<Map<String, dynamic>?> sendMessage(String conversationId, String content) async {
    try {
      final response = await ApiClient.post('/conversations/$conversationId/messages', data: {
        'content': content,
        'messageType': 'TEXT',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        final data = (resData is Map && resData.containsKey('data'))
            ? resData['data'] as Map<String, dynamic>?
            : (response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : null);
        WebSocketService.send({
          'content': content,
          'messageType': 'TEXT',
        }, destination: '/app/chat.send/$conversationId');
        return data;
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }

  /// WhatsApp-style: Share a file in a conversation via multipart upload.
  /// Pipeline: Upload to server → S3 → PostgreSQL → WebSocket → Kafka FCM
  static Future<Map<String, dynamic>?> sendFileMessage(
    String conversationId, {
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      late final MultipartFile multipartFile;
      if (bytes != null) {
        multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      } else if (file != null) {
        multipartFile = await MultipartFile.fromFile(file.path, filename: fileName);
      } else {
        return null;
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await ApiClient.post(
        '/conversations/$conversationId/files',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return resData is Map<String, dynamic> ? resData : null;
      }
    } catch (e) {
      print('Error sending file message: $e');
    }
    return null;
  }

  /// WhatsApp-style: Share a file using presigned URL (client already uploaded to S3)
  static Future<Map<String, dynamic>?> sendFileAttachment(
    String conversationId, {
    required String fileKey,
    required String fileUrl,
    required String fileName,
    required int fileSizeBytes,
    required String mimeType,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await ApiClient.post(
        '/conversations/$conversationId/files/presigned',
        data: {
          'fileKey': fileKey,
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileSizeBytes': fileSizeBytes,
          'mimeType': mimeType,
          'thumbnailUrl': thumbnailUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return resData is Map<String, dynamic> ? resData : null;
      }
    } catch (e) {
      print('Error sending file attachment: $e');
    }
    return null;
  }

  /// Create or fetch an existing 1-to-1 conversation with another user
  static Future<String?> createConversation(String targetUserId) async {
    try {
      final response = await ApiClient.post('/conversations', data: {
        'recipientId': targetUserId,
        'isGroup': false,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['id']?.toString();
        }
        return response.data['id']?.toString();
      }
    } catch (e) {
      print('Error creating conversation: $e');
    }
    return null;
  }
}

