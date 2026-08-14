import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';
import '../../../../common/models/profile_model.dart';

abstract class SearchRepository {
  Future<List<ProfileModel>> search(String query);
  Future<List<String>> getSearchHistory();
}

class SearchRepositoryImpl implements SearchRepository {
  @override
  Future<List<ProfileModel>> search(String query) async {
    final response = await ApiClient.get('/search/profiles', queryParameters: {'q': query});
    if (response.data is List) {
      return (response.data as List).map((e) => ProfileModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<String>> getSearchHistory() async {
    final response = await ApiClient.get('/search/history');
    if (response.data is List) {
      return (response.data as List).map((e) => e.toString()).toList();
    }
    return [];
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepositoryImpl());

final searchStateProvider = StateNotifierProvider<SearchNotifier, AsyncState<List<ProfileModel>>>((ref) {
  return SearchNotifier(repository: ref.watch(searchRepositoryProvider));
});

class SearchNotifier extends StateNotifier<AsyncState<List<ProfileModel>>> {
  final SearchRepository repository;
  SearchNotifier({required this.repository}) : super(const AsyncState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncState(status: Status.empty, data: []);
      return;
    }
    state = state.copyWith(status: Status.loading);
    try {
      final results = await repository.search(query);
      state = AsyncState(
        status: results.isEmpty ? Status.empty : Status.success,
        data: results,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  void clear() {
    state = const AsyncState(status: Status.initial, data: []);
  }
}
