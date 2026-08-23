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
      final response = await ApiClient.get('/profiles/$targetUserId');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData['data'] is Map) {
          final isFol = resData['data']['isFollowing'] ?? resData['data']['is_following'];
          if (isFol is bool) {
            setFollowState(targetUserId, isFol);
            return isFol;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> follow(String targetUserId) async {
    setFollowState(targetUserId, true);
    try {
      final response = await ApiClient.post('/users/$targetUserId/follow');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final serverState = resData['data']?['isFollowing'] ?? resData['data']?['is_following'];
          if (serverState is bool) {
            setFollowState(targetUserId, serverState);
            return serverState;
          }
        }
        return true;
      }
    } catch (e) {
      debugPrint('[FollowService] Error following on backend: $e');
      setFollowState(targetUserId, false);
      return false;
    }
    return true;
  }

  static Future<bool> unfollow(String targetUserId) async {
    setFollowState(targetUserId, false);
    try {
      final response = await ApiClient.delete('/users/$targetUserId/follow');
      if (response.statusCode == 200 || response.statusCode == 204) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final serverState = resData['data']?['isFollowing'] ?? resData['data']?['is_following'];
          if (serverState is bool) {
            setFollowState(targetUserId, serverState);
            return serverState;
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('[FollowService] Error unfollowing on backend: $e');
      setFollowState(targetUserId, true);
      return true;
    }
    return false;
  }

  static Future<bool> toggleFollow(String targetUserId, bool currentFollowState) async {
    final newState = !currentFollowState;
    if (newState) {
      return follow(targetUserId);
    } else {
      return unfollow(targetUserId);
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    final cleanId = userId.trim().isEmpty ? 'me' : userId.trim();
    try {
      final response = await ApiClient.get('/profiles/$cleanId/followers');
      if (response.statusCode == 200) {
        final resData = response.data;
        List rawList = [];
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) rawList = payload;
        } else if (resData is List) {
          rawList = resData;
        }
        final list = List<Map<String, dynamic>>.from(rawList);
        for (final item in list) {
          final id = item['id']?.toString();
          final isFol = item['isFollowing'] ?? item['is_following'];
          if (id != null && isFol is bool) {
            _followStates[id] = isFol;
          }
        }
        return list;
      }
    } catch (e) {
      debugPrint('[FollowService] /profiles/$cleanId/followers failed: $e, trying /users/$cleanId/followers');
      try {
        final response = await ApiClient.get('/users/$cleanId/followers');
        if (response.statusCode == 200) {
          final resData = response.data;
          List rawList = [];
          if (resData is Map && resData.containsKey('data')) {
            final payload = resData['data'];
            if (payload is List) rawList = payload;
          } else if (resData is List) {
            rawList = resData;
          }
          final list = List<Map<String, dynamic>>.from(rawList);
          for (final item in list) {
            final id = item['id']?.toString();
            final isFol = item['isFollowing'] ?? item['is_following'];
            if (id != null && isFol is bool) {
              _followStates[id] = isFol;
            }
          }
          return list;
        }
      } catch (e2) {
        debugPrint('[FollowService] Error getting followers: $e2');
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    final cleanId = userId.trim().isEmpty ? 'me' : userId.trim();
    try {
      final response = await ApiClient.get('/profiles/$cleanId/following');
      if (response.statusCode == 200) {
        final resData = response.data;
        List rawList = [];
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) rawList = payload;
        } else if (resData is List) {
          rawList = resData;
        }
        final list = List<Map<String, dynamic>>.from(rawList);
        for (final item in list) {
          final id = item['id']?.toString();
          final isFol = item['isFollowing'] ?? item['is_following'];
          if (id != null && isFol is bool) {
            _followStates[id] = isFol;
          }
        }
        return list;
      }
    } catch (e) {
      debugPrint('[FollowService] /profiles/$cleanId/following failed: $e, trying /users/$cleanId/following');
      try {
        final response = await ApiClient.get('/users/$cleanId/following');
        if (response.statusCode == 200) {
          final resData = response.data;
          List rawList = [];
          if (resData is Map && resData.containsKey('data')) {
            final payload = resData['data'];
            if (payload is List) rawList = payload;
          } else if (resData is List) {
            rawList = resData;
          }
          final list = List<Map<String, dynamic>>.from(rawList);
          for (final item in list) {
            final id = item['id']?.toString();
            final isFol = item['isFollowing'] ?? item['is_following'];
            if (id != null && isFol is bool) {
              _followStates[id] = isFol;
            }
          }
          return list;
        }
      } catch (e2) {
        debugPrint('[FollowService] Error getting following: $e2');
      }
    }
    return [];
  }
}
