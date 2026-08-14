import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class ClubEntity {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int memberCount;
  final String? logoUrl;

  const ClubEntity({
    required this.id,
    required this.name,
    this.description,
    this.category = 'Technical',
    this.memberCount = 1,
    this.logoUrl,
  });

  factory ClubEntity.fromJson(Map<String, dynamic> json) {
    return ClubEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Club',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'Technical',
      memberCount: (json['memberCount'] ?? json['member_count'] ?? 1) as int,
      logoUrl: json['logoUrl'] ?? json['logo_url'],
    );
  }
}

final clubsStateProvider = FutureProvider<List<ClubEntity>>((ref) async {
  final response = await ApiClient.get('/clubs');
  if (response.data is List) {
    return (response.data as List).map((e) => ClubEntity.fromJson(e)).toList();
  }
  return [];
});
