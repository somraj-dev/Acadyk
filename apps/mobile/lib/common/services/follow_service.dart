import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';

class FollowService {
  static final ValueNotifier<int> followChangeNotifier = ValueNotifier<int>(0);
  static final Map<String, bool> _followStates = {};

  static bool getFollowState(String targetUserId, {bool defaultState = false}) {
    return _followStates[targetUserId] ?? defaultState;
  }

  static void setFollowState(String targetUserId, bool isFollowing) {
    _followStates[targetUserId] = isFollowing;
    followChangeNotifier.value = followChangeNotifier.value + 1;
  }

  static Future<bool> isFollowing(String targetUserId) async {
    if (_followStates.containsKey(targetUserId)) {
      return _followStates[targetUserId]!;
    }
    try {
      final response = await ApiClient.get('/profiles/$targetUserId/followers');
      if (response.statusCode == 200) {
        return false;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> toggleFollow(String targetUserId, bool currentFollowState) async {
    final newState = !currentFollowState;
    setFollowState(targetUserId, newState);

    try {
      final response = await ApiClient.post('/profiles/$targetUserId/follow');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final serverState = resData['data']?['isFollowing'];
          if (serverState is bool) {
            setFollowState(targetUserId, serverState);
            return serverState;
          }
        }
      }
    } catch (e) {
      debugPrint('[FollowService] Error toggling follow on backend: $e');
    }
    return newState;
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId/followers');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) return List<Map<String, dynamic>>.from(payload);
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      debugPrint('[FollowService] Error getting followers: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId/following');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) return List<Map<String, dynamic>>.from(payload);
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      debugPrint('[FollowService] Error getting following: $e');
    }
    return [];
  }
}
