# Phase 7: Home Feed UX Specification & Design System

This document defines the complete visual layout, typography, color palettes, spacing systems, interactive elements, motion design, and Flutter engineering blueprints for the **Acadyk Home Feed** application.

---

## 🎨 Design System Specifications

Our design system balances professional credibility (clean layouts, rich data visualization) with modern product aesthetics (obsidian dark mode, glassmorphic headers, neon electric accent states).

### 1. Typography Scale (Primary Font: Inter | Header Font: Outfit)

Excellent readability is the core goal. We configure tight letter-spacing for large headers and generous line-height for body content:

| Style Class | Font Family | Size (sp) | Weight | Line Height | Letter Spacing | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Large** | Outfit | 32.0 | 700 (Bold) | 1.25 | -0.8px | Screen title headers |
| **Heading Medium**| Outfit | 20.0 | 600 (Semibold)| 1.30 | -0.4px | Card section titles |
| **Subheading** | Inter | 15.0 | 600 (Semibold)| 1.35 | -0.1px | User names, post labels |
| **Body Primary**  | Inter | 14.0 | 400 (Regular) | 1.50 | 0.0px | Post text, descriptions |
| **Body Secondary**| Inter | 13.0 | 400 (Regular) | 1.45 | 0.0px | Timestamps, details |
| **Caption** | Inter | 11.0 | 400 (Regular) | 1.40 | +0.2px | Footnotes, legal terms |
| **Button Text** | Inter | 14.0 | 600 (Semibold)| 1.20 | +0.1px | Primary buttons, CTA labels |

---

### 2. Color System Palette

The color system communicates trust, innovation, and analytical clarity. We provide design tokens mapping semantic meanings to Hex values:

```
┌────────────────────────────────────────────────────────┐
│                   Color Token Schema                   │
├────────────────────────────────────────────────────────┤
│ Primary Background               : #0B0F19             │
│ Surface (Feed Cards)             : #161D30             │
│ Surface Hover/Elevated           : #202A45             │
│ Outline (Card Borders)           : #232E4A             │
│ Primary Blue Accent (Brand)      : #3B82F6             │
│ Secondary Purple (AI Engine)     : #A855F7             │
│ Success Green (Verified checks)  : #10B981             │
│ Warning Orange (Flagged assets)  : #F59E0B             │
│ Error Red (Alerts, deletions)    : #EF4444             │
│ Text Title (High Contrast)       : #F9FAFB             │
│ Text Subtitle (Muted Grey)       : #9CA3AF             │
│ Icon Base (Neutral Grey)         : #9CA3AF             │
└────────────────────────────────────────────────────────┘
```

---

### 3. Spacing, Border Radius & Elevation Systems

* **Spacing Grid**: Enforce a strict 4dp-based base layout grid.
  * `4dp` (Micro gaps, padding inside chips).
  * `8dp` (Internal padding between elements inside cards).
  * `12dp` (Padding between user titles and post contents).
  * `16dp` (Default page padding and default card padding).
  * `24dp` (Spacer sizes between sections).
  * `32dp` & `40dp` (Top status bar offsets).
* **Border Radii**:
  * `Card / Image Border Radius`: `16.0` (smooth rounded corners).
  * `Button / Input Border Radius`: `24.0` (pill-shaped buttons).
  * `Chip / Small Container Border Radius`: `8.0` (tag pill shapes).
  * `Avatars`: Circular shape (`shape: BoxShape.circle`).
* **Subtle Elevation Shadows**:
  Avoid muddy dropshadows. For floating cards, we stack two subtle, low-opacity shadow layers:
  ```css
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 
              0 2px 4px -2px rgba(0, 0, 0, 0.05);
  ```

---

## 📱 Home Feed Screen Layout Wireframe

This layout represents the responsive phone interface design:

```
┌───────────────────────────────────────────────────────────┐
│ [Avatar] [🔍 Search everything with AI... ]   [+]  [✉]  [🔔]│ <-- Top App Bar
├───────────────────────────────────────────────────────────┤
│  Suggested:  (⚡ AI Summary)  (📁 Jobs)  (🎓 LMS)  (🏢 Orgs) │ <-- Story Quick Actions
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ [Avatar]  Alina Sprengele [✓] Verified   [+ Follow] │  │ <-- Card Header
│  │           CEO @ Vibe Skills | 4h ago                │  │
│  │ ─────────────────────────────────────────────────── │  │
│  │  A $24M seed valuation is a death sentence.         │  │ <-- Content Block
│  │  Zero PMF. 100% pressure.                           │  │
│  │                                                     │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │                  [MEDIA BLOC]                 │  │  │ <-- Media Box (Image/Video)
│  │  └───────────────────────────────────────────────┘  │  │
│  │                                                     │  │
│  │  ┌───────────────────────────────────────────────┐  │  │
│  │  │ 🤖 AI SUMMARY: High runway burn mitigations...│  │  │ <-- Inline AI Assist Panel
│  │  └───────────────────────────────────────────────┘  │  │
│  │ ─────────────────────────────────────────────────── │  │
│  │  👍 Appreciate  💡 Insightful  🔁 Repost  💾 Save   │  │ <-- Engagement Section
│  │  (142 likes)  (28 comments)                         │  │
│  │  [Add Comment...]                                   │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                           │
├───────────────────────────────────────────────────────────┤
│   [Home]     [Network]     [🧠 AI]     [Alerts]   [Profile] │ <-- Bottom Navigation
└───────────────────────────────────────────────────────────┘
```

---

## 🧩 Reusable Component Specifications

### 1. The Top App Bar
* **Branding & Avatar**: Rounded user avatar on the left.
* **Intelligent AI Search**: A central search bar that accepts natural language (e.g. *"Show me Flutter jobs in Boston"*). Displays a glowing amethyst gradient outline (`#A855F7`) when focused.
* **Quick Create (+)**: Starts a post creation layout with markdown and code snippets support.
* **Message & Notification Triggers**: Triggers unread badge count indicators.

### 2. The Custom Feed Card
Each post sits inside a clean surface container (`#161D30`) with a thin border outline (`#232E4A`). It separates layout components into logical rows:

#### A. Card Header Component
* **Avatar & Name block**: Displays the author's avatar, verified credentials check icon, name, professional headline, and timestamp.
* **Contextual follow button**: Visible only if the current user does not follow the author.
* **Options dropdown menu**: Triggered by a three-dots menu icon on the right.

#### B. Content & Media block
* **Post text**: Auto-truncated with a "...more" button if exceeding 3 lines.
* **Custom Code Snippet Widget**: Displays code commits with syntax highlighting.
* **Research Paper Snippet**: Displays the title, citation metrics, and DOI link.
* **Media Container**: Constrained to a standard mobile width, border radius `16.0`, containing images or inline video players.

#### C. Card AI Assist Panel
An inline card block with an amethyst outline gradient containing AI utilities:
* **AI Summary**: Collapsed by default. Tapping reveals a 3-bullet point summary of the post's contents.
* **Ask AI**: Direct text box to ask questions on the post's attachments (e.g. asking to explain a code block or compile a research summary).

#### D. Engagement Panel
* **Action Buttons**: Four icons with text (Appreciate, Insightful, Repost, Save).
* **Appreciate**: Replaces generic likes with high-signal endorsements.
* **Insightful**: Endorsement indicating technical or intellectual quality.
* **Feedback Counters**: Small counts below the actions showing comment list volumes.

---

## 🐹 Flutter Widgets Hierarchy & Architecture

We implement this layout using a decoupled widget structure. Data and states are managed via Riverpod `AsyncNotifierProvider` classes:

```
HomeFeedScreen (Scaffold)
 └── CustomScrollView (Slivers)
      ├── TopFeedAppBar (SliverPersistentHeader with Glassmorphism)
      ├── StoryQuickActionsRow (SliverToBoxAdapter with Horizontal ListView)
      └── FeedCardList (SliverList)
           └── FeedCard (Stateful Card Widget)
                ├── CardHeader
                ├── CardBodyContent (Supports custom text, images, code canvas)
                ├── CardAIAssistPanel (Inline RAG Summarizer)
                └── CardEngagementRow
```

### 1. Riverpod Feed State Provider
Loads paginated posts from the Go backend. Automatically appends new posts when scrolling reaches bottom boundaries:

```dart
final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(() {
  return FeedNotifier();
});

class FeedNotifier extends AsyncNotifier<List<Post>> {
  final _feedService = FeedService();
  int _currentPage = 1;

  @override
  Future<List<Post>> build() async {
    return _feedService.fetchFeed(page: _currentPage);
  }

  Future<void> fetchNextPage() async {
    _currentPage++;
    final newPosts = await _feedService.fetchFeed(page: _currentPage);
    state = AsyncValue.data([...state.value ?? [], ...newPosts]);
  }
}
```

### 2. Interaction & Motion Rules
* **Pull-to-refresh**: standard indicator trigger refreshes feed data.
* **Card Entrance**: Cards animate using a vertical offset shift and opacity fade transition during scroll loads:
  ```dart
  AnimatedOpacity(
    opacity: isVisible ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 300),
    child: widget,
  )
  ```
* **Double-tap Appreciate**: Double-tapping the card content triggers a heart shape animation popup over the center of the card.
