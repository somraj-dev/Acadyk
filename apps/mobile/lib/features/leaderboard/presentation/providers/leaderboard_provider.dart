import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';

class LeaderboardItem {
  final int rank;
  final ProfileEntity profile;
  final int score;
  final String category;

  const LeaderboardItem({
    required this.rank,
    required this.profile,
    required this.score,
    required this.category,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: (json['rank'] ?? 1) as int,
      profile: ProfileDto.fromJson(json['profile'] ?? {}),
      score: (json['score'] ?? 0) as int,
      category: json['category']?.toString() ?? 'Global',
    );
  }
}

final leaderboardStateProvider = FutureProvider<List<LeaderboardItem>>((ref) async {
  final response = await ApiClient.get('/leaderboard');
  if (response.data is List) {
    return (response.data as List).map((e) => LeaderboardItem.fromJson(e)).toList();
  }
  return [];
});
