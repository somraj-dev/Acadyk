# Phase 7: UI/UX Planning & Flutter Mobile Standards

This document outlines the UI/UX design language, accessibility targets, typography, color system, and development guidelines for our Flutter mobile applications.

---

## 🎨 Visual Aesthetics & Theme (Material 3)

The Flutter application implements **Material Design 3** styled with a premium dark-mode obsidian visual theme.

```
┌────────────────────────────────────────────────────────┐
│               Flutter App Color Tokens                 │
├────────────────────────────────────────────────────────┤
│ Background                       : Color(0xFF0B0F19)   │
│ Surface                          : Color(0xFF161D30)   │
│ Outline/Border                   : Color(0xFF232E4A)   │
│ Primary Accent (Electric Blue)   : Color(0xFF3B82F6)   │
│ Secondary Accent (Deep Amethyst) : Color(0xFFA855F7)   │
│ Text (Primary)                   : Color(0xFFF9FAFB)   │
│ Text (Secondary)                 : Color(0xFF9CA3AF)   │
└────────────────────────────────────────────────────────┘
```

---

## 🏗️ Flutter Mobile Architecture & Packages

To guarantee scalability and keep features independent, we follow **Clean Architecture (Feature-First folder structure)**.

```
lib/
├── app/
│   ├── router/                 # GoRouter configurations
│   └── theme/                  # M3 App Theme configurations
├── common/                     # Global shared widgets and network utilities
│   └── network/                # Dio client HTTP interceptors
└── features/                   # Core business features
    ├── auth/
    ├── feed/
    │   ├── data/               # Models, Data Sources (Dio), Repositories Impl
    │   │   ├── models/         # Freezed immutable classes
    │   │   └── datasources/
    │   ├── domain/             # Entities, Repositories definitions, Use Cases
    │   └── presentation/       # Riverpod Providers, Controllers, Screen UI Widgets
    └── profiles/
```

### 1. State Management (Riverpod)
We use **Riverpod** for declarative state management. State transitions are controlled via Notifier classes:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_state.freezed.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState.initial() = _Initial;
  const factory FeedState.loading() = _Loading;
  const factory FeedState.loaded(List<Post> posts) = _Loaded;
  const factory FeedState.error(String message) = _Error;
}
```

### 2. Network Client (Dio)
We configure a single **Dio** instance with logging and JWT auth header injection interceptors:
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.acadyk.com/api/v1'));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(tokenStorageProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));
  return dio;
});
```

---

## 📱 Mobile Screen Layout Guidelines

Every screen implemented in Flutter must handle 5 distinct visual states to ensure premium UX quality:

1. **Loading State**: Customized Material 3 shimmer blocks that mimic actual widget layouts.
2. **Loaded State**: Rendered widgets utilizing `Sliver` scroll elements for smooth scrolling performance.
3. **Empty State**: Custom vector illustrations with descriptive text and call-to-action buttons (e.g. *"No jobs match your profile yet. Add more skills to increase matches!"*).
4. **Error State**: Displays a descriptive error message with a "Retry" button.
5. **Responsive Layouts**: Utilizing `LayoutBuilder` to toggle between single-pane mobile feeds and double-pane layouts on tablet displays.

---

## ♿ Mobile Accessibility (WCAG 2.1 AA Compliance)
* **Touch Targets**: All buttons, links, and text fields must have a minimum touch target area of **48x48 logical pixels** to prevent click errors.
* **Semantic Trees**: Annotate all image assets with the `Semantics` widget to supply text summaries to screen reader software (TalkBack/VoiceOver).
  ```dart
  Semantics(
    label: 'User Profile Avatar',
    child: CircleAvatar(backgroundImage: NetworkImage(user.avatarURL)),
  )
  ```
