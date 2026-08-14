import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class StartupEntity {
  final String id;
  final String name;
  final String? pitch;
  final String stage;
  final String? industry;
  final String? logoUrl;
  final String? founderName;

  const StartupEntity({
    required this.id,
    required this.name,
    this.pitch,
    this.stage = 'Idea',
    this.industry,
    this.logoUrl,
    this.founderName,
  });

  factory StartupEntity.fromJson(Map<String, dynamic> json) {
    return StartupEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Startup',
      pitch: json['pitch']?.toString(),
      stage: json['stage']?.toString() ?? 'Idea',
      industry: json['industry']?.toString(),
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      founderName: json['founderName'] ?? json['founder_name'],
    );
  }
}

final startupsStateProvider = FutureProvider<List<StartupEntity>>((ref) async {
  final response = await ApiClient.get('/startups');
  if (response.data is List) {
    return (response.data as List).map((e) => StartupEntity.fromJson(e)).toList();
  }
  return [];
});
