import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';

class OpportunityEntity {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? company;
  final String? location;
  final String? stipendOrSalary;
  final String? applyUrl;

  const OpportunityEntity({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Internship',
    this.company,
    this.location,
    this.stipendOrSalary,
    this.applyUrl,
  });

  factory OpportunityEntity.fromJson(Map<String, dynamic> json) {
    return OpportunityEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Opportunity',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'Internship',
      company: json['company']?.toString(),
      location: json['location']?.toString(),
      stipendOrSalary: json['stipendOrSalary'] ?? json['stipend_or_salary'],
      applyUrl: json['applyUrl'] ?? json['apply_url'],
    );
  }
}

final opportunitiesStateProvider = FutureProvider<List<OpportunityEntity>>((ref) async {
  final response = await ApiClient.get('/opportunities');
  if (response.data is List) {
    return (response.data as List).map((e) => OpportunityEntity.fromJson(e)).toList();
  }
  return [];
});
