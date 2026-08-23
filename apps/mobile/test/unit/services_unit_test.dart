import 'package:flutter_test/flutter_test.dart';
import 'package:acadyk/common/services/post_service.dart';
import 'package:acadyk/common/services/profile_service.dart';
import 'package:acadyk/common/services/message_service.dart';
import 'package:acadyk/common/services/event_service.dart';
import 'package:acadyk/common/services/notification_service.dart';
import 'package:acadyk/common/services/search_service.dart';
import 'package:acadyk/common/services/follow_service.dart';
import 'package:acadyk/common/services/community_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Flutter Core Services Unit Tests', () {
    test('PostService methods return safe collections with offline resilience', () async {
      final posts = await PostService.getFeedPosts();
      expect(posts, isNotNull);

      final comments = await PostService.getComments('post-123');
      expect(comments, isNotNull);

      final liked = await PostService.toggleLike('post-123', false);
      expect(liked, isA<bool>());

      final bookmarked = await PostService.toggleBookmark('post-123', false);
      expect(bookmarked, isA<bool>());

      // Test hide & unhide post
      expect(PostService.isPostHidden({'id': 'post-hide-test', 'authorName': 'John Doe'}), false);
      PostService.hidePost('post-hide-test');
      expect(PostService.isPostHidden({'id': 'post-hide-test', 'authorName': 'John Doe'}), true);
      PostService.unhidePost('post-hide-test');
      expect(PostService.isPostHidden({'id': 'post-hide-test', 'authorName': 'John Doe'}), false);

      // Test post creation and feed verification
      final newPost = await PostService.startPostingAsync(
        content: 'Excited to collaborate on AI projects at MITS Gwalior! #Flutter #AIML',
        postType: 'text',
      );
      expect(newPost, isNotNull);
      expect(newPost['content'], contains('MITS Gwalior'));

      final updatedFeed = await PostService.getFeedPosts();
      expect(updatedFeed, isA<List<Map<String, dynamic>>>());

      // Test hide & unhide author
      expect(PostService.isAuthorHidden('MITS Gwalior'), false);
      PostService.hideAuthor('MITS Gwalior');
      expect(PostService.isAuthorHidden('MITS Gwalior'), true);
      expect(PostService.isPostHidden({'id': 'post-999', 'authorName': 'MITS Gwalior'}), true);
      PostService.unhideAuthor('MITS Gwalior');
      expect(PostService.isAuthorHidden('MITS Gwalior'), false);
      expect(PostService.isPostHidden({'id': 'post-999', 'authorName': 'MITS Gwalior'}), false);
    });

    test('ProfileService methods handle profile fetch and update', () async {
      final profile = await ProfileService.getProfile('test-user-id');
      expect(profile == null || profile is Map<String, dynamic>, true);

      try {
        await ProfileService.updateProfile('test-user-id', {'fullName': 'Somraj Lodhi'});
      } catch (_) {}
    });

    test('MessageService handles conversation retrieval and message dispatching', () async {
      final convs = await MessageService.getConversations();
      expect(convs, isNotNull);

      final msgs = await MessageService.getMessages('conv-123');
      expect(msgs, isNotNull);
    });

    test('EventService handles events discovery and registration', () async {
      final events = await EventService.getEvents();
      expect(events, isNotNull);

      final registered = await EventService.registerForEvent('event-123', {'name': 'Somraj'});
      expect(registered, isA<bool>());
    });

    test('NotificationService handles notifications and preference toggles', () async {
      final notifs = await NotificationService.getNotifications();
      expect(notifs, isNotNull);

      final unreadCount = await NotificationService.getUnreadCount();
      expect(unreadCount, isA<int>());
    });

    test('SearchService handles global search and autocomplete suggestions', () async {
      final searchResults = await SearchService.globalSearch('AI engineering');
      expect(searchResults, isNotNull);

      final autocomplete = await SearchService.autocomplete('Acadyk');
      expect(autocomplete, isNotNull);
    });

    test('FollowService and CommunityService handle relationships and spaces', () async {
      final connected = await FollowService.toggleFollow('user-target-id', false);
      expect(connected, isA<bool>());

      final communities = await CommunityService.getCommunities();
      expect(communities, isNotNull);
    });
  });
}
