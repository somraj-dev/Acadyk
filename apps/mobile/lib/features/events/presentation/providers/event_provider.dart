import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/usecase/usecase.dart';

class EventEntity {
  final String id;
  final String title;
  final String? description;
  final String eventType;
  final String? location;
  final String? bannerUrl;
  final String? organizerName;
  final bool isRegistered;

  const EventEntity({
    required this.id,
    required this.title,
    this.description,
    this.eventType = 'workshop',
    this.location,
    this.bannerUrl,
    this.organizerName,
    this.isRegistered = false,
  });

  EventEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? eventType,
    String? location,
    String? bannerUrl,
    String? organizerName,
    bool? isRegistered,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      location: location ?? this.location,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      organizerName: organizerName ?? this.organizerName,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}

class EventDto extends EventEntity {
  const EventDto({
    required super.id,
    required super.title,
    super.description,
    super.eventType,
    super.location,
    super.bannerUrl,
    super.organizerName,
    super.isRegistered,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      description: json['description']?.toString(),
      eventType: json['eventType'] ?? json['event_type'] ?? 'workshop',
      location: json['location']?.toString(),
      bannerUrl: json['bannerUrl'] ?? json['banner_url'],
      organizerName: json['organizerName'] ?? json['organizer_name'],
      isRegistered: json['isRegistered'] ?? json['is_registered'] ?? false,
    );
  }
}

abstract class EventRepository {
  Future<List<EventEntity>> getEvents();
  Future<bool> registerEvent(String eventId, Map<String, dynamic> data);
}

class EventRepositoryImpl implements EventRepository {
  @override
  Future<List<EventEntity>> getEvents() async {
    final response = await ApiClient.get('/events');
    if (response.data is List) {
      return (response.data as List).map((e) => EventDto.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> registerEvent(String eventId, Map<String, dynamic> data) async {
    final response = await ApiClient.post('/events/$eventId/register', data: data);
    return response.data?['registered'] == true;
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) => EventRepositoryImpl());

final eventsStateProvider = StateNotifierProvider<EventsNotifier, AsyncState<List<EventEntity>>>((ref) {
  return EventsNotifier(repository: ref.watch(eventRepositoryProvider));
});

class EventsNotifier extends StateNotifier<AsyncState<List<EventEntity>>> {
  final EventRepository repository;

  EventsNotifier({required this.repository}) : super(const AsyncState()) {
    fetchEvents();
  }

  Future<void> fetchEvents({bool refresh = false}) async {
    if (refresh) state = state.copyWith(isRefreshing: true);
    else state = state.copyWith(status: Status.loading);

    try {
      final events = await repository.getEvents();
      state = AsyncState(
        status: events.isEmpty ? Status.empty : Status.success,
        data: events,
        isRefreshing: false,
      );
    } catch (e) {
      state = AsyncState(status: Status.error, errorMessage: e.toString(), data: []);
    }
  }

  Future<bool> register(String eventId, Map<String, dynamic> payload) async {
    try {
      final success = await repository.registerEvent(eventId, payload);
      if (success && state.data != null) {
        final updated = state.data!.map((e) => e.id == eventId ? e.copyWith(isRegistered: true) : e).toList();
        state = state.copyWith(data: updated);
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}
