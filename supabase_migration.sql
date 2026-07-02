-- ============================================================
-- Acadyk Supabase Migration — Complete Schema
-- Run this in Supabase SQL Editor (Dashboard → SQL → New Query)
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  email TEXT,
  bio TEXT,
  profile_photo_url TEXT,
  cover_photo_url TEXT,
  college TEXT,
  skills TEXT[] DEFAULT '{}',
  location TEXT,
  website TEXT,
  social_links JSONB DEFAULT '{}',
  is_verified BOOLEAN DEFAULT FALSE,
  is_premium BOOLEAN DEFAULT FALSE,
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  posts_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, username)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    LOWER(REPLACE(COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)), ' ', '')) || '_' || SUBSTR(NEW.id::TEXT, 1, 6)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 2. POSTS
-- ============================================================
CREATE TABLE IF NOT EXISTS posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  post_type TEXT DEFAULT 'text', -- text, image, poll, article
  visibility TEXT DEFAULT 'public', -- public, connections, private
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- ============================================================
-- 3. POST IMAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS post_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_post_images_post_id ON post_images(post_id);

-- ============================================================
-- 4. COMMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE, -- nested replies
  content TEXT NOT NULL,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);

-- ============================================================
-- 5. LIKES
-- ============================================================
CREATE TABLE IF NOT EXISTS likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id),
  CONSTRAINT like_target CHECK (
    (post_id IS NOT NULL AND comment_id IS NULL) OR
    (post_id IS NULL AND comment_id IS NOT NULL)
  )
);

CREATE INDEX idx_likes_post_id ON likes(post_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);

-- ============================================================
-- 6. BOOKMARKS
-- ============================================================
CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, post_id)
);

CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);

-- ============================================================
-- 7. FOLLOWERS
-- ============================================================
CREATE TABLE IF NOT EXISTS followers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id),
  CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX idx_followers_follower ON followers(follower_id);
CREATE INDEX idx_followers_following ON followers(following_id);

-- Trigger to update follower/following counts
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE profiles SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
    UPDATE profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE profiles SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = OLD.following_id;
    UPDATE profiles SET following_count = GREATEST(following_count - 1, 0) WHERE id = OLD.follower_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_change ON followers;
CREATE TRIGGER on_follow_change
  AFTER INSERT OR DELETE ON followers
  FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- ============================================================
-- 8. NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  type TEXT NOT NULL, -- follow, like, comment, mention, team_invite, event_registration, connection_request, collab_request, repost
  title TEXT,
  body TEXT,
  reference_id UUID, -- post_id, event_id, team_id, etc.
  reference_type TEXT, -- post, event, team, comment
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(recipient_id) WHERE is_read = FALSE;

-- ============================================================
-- 9. CONVERSATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  is_group BOOLEAN DEFAULT FALSE,
  group_name TEXT,
  group_avatar_url TEXT,
  last_message_text TEXT,
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 10. CONVERSATION PARTICIPANTS
-- ============================================================
CREATE TABLE IF NOT EXISTS conversation_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ,
  UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);

-- ============================================================
-- 11. MESSAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT,
  message_type TEXT DEFAULT 'text', -- text, image, file
  attachment_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);

-- Trigger to update conversation last message
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET last_message_text = NEW.content,
      last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_new_message ON messages;
CREATE TRIGGER on_new_message
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();

-- ============================================================
-- 12. COMPANIES
-- ============================================================
CREATE TABLE IF NOT EXISTS companies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  cover_url TEXT,
  industry TEXT,
  website TEXT,
  location TEXT,
  employee_count INT DEFAULT 0,
  founded_year INT,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 13. COMPANY MEMBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS company_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member', -- admin, member, viewer
  title TEXT,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(company_id, user_id)
);

-- ============================================================
-- 14. EVENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  organizer TEXT,
  organizer_logo_url TEXT,
  banner_url TEXT,
  event_type TEXT DEFAULT 'hackathon', -- hackathon, workshop, competition, webinar, conference
  mode TEXT DEFAULT 'online', -- online, offline, hybrid
  location TEXT,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  registration_deadline TIMESTAMPTZ,
  max_participants INT,
  prize_pool TEXT,
  eligibility TEXT,
  tags TEXT[] DEFAULT '{}',
  website_url TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  registrations_count INT DEFAULT 0,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_events_created_at ON events(created_at DESC);

-- ============================================================
-- 15. EVENT REGISTRATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS event_registrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  team_id UUID,
  status TEXT DEFAULT 'registered', -- registered, confirmed, cancelled, waitlisted
  registered_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_reg_user ON event_registrations(user_id);

-- Update event registration count trigger
CREATE OR REPLACE FUNCTION update_event_registration_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE events SET registrations_count = registrations_count + 1 WHERE id = NEW.event_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE events SET registrations_count = GREATEST(registrations_count - 1, 0) WHERE id = OLD.event_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_event_registration_change ON event_registrations;
CREATE TRIGGER on_event_registration_change
  AFTER INSERT OR DELETE ON event_registrations
  FOR EACH ROW EXECUTE FUNCTION update_event_registration_count();

-- ============================================================
-- 16. TEAMS
-- ============================================================
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  logo_url TEXT,
  max_members INT DEFAULT 5,
  is_open BOOLEAN DEFAULT TRUE,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 17. TEAM MEMBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS team_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member', -- leader, member
  status TEXT DEFAULT 'pending', -- pending, accepted, rejected
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(team_id, user_id)
);

-- ============================================================
-- 18. COMMUNITIES
-- ============================================================
CREATE TABLE IF NOT EXISTS communities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  avatar_url TEXT,
  cover_url TEXT,
  category TEXT,
  rules TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  members_count INT DEFAULT 0,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 19. COMMUNITY MEMBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS community_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member', -- admin, moderator, member
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(community_id, user_id)
);

-- ============================================================
-- 20. LEADERBOARDS
-- ============================================================
CREATE TABLE IF NOT EXISTS leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category TEXT DEFAULT 'overall', -- overall, hackathons, posts, engagement
  score INT DEFAULT 0,
  rank INT,
  period TEXT DEFAULT 'alltime', -- weekly, monthly, alltime
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leaderboards_category ON leaderboards(category, score DESC);

-- ============================================================
-- 21. ACHIEVEMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  badge_icon TEXT,
  earned_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 22. PREMIUM SUBSCRIPTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS premium_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  plan TEXT DEFAULT 'basic', -- basic, pro, enterprise
  status TEXT DEFAULT 'active', -- active, cancelled, expired
  started_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  UNIQUE(user_id)
);

-- ============================================================
-- 23. VERIFICATION REQUESTS
-- ============================================================
CREATE TABLE IF NOT EXISTS verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  document_url TEXT,
  reason TEXT,
  status TEXT DEFAULT 'pending', -- pending, approved, rejected
  reviewed_by UUID REFERENCES profiles(id),
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ
);

-- ============================================================
-- 24. USER SETTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  dark_mode BOOLEAN DEFAULT FALSE,
  language TEXT DEFAULT 'en',
  privacy_profile TEXT DEFAULT 'public', -- public, connections, private
  privacy_activity TEXT DEFAULT 'public',
  privacy_messages TEXT DEFAULT 'everyone', -- everyone, connections, nobody
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- ============================================================
-- 25. SEARCH HISTORY
-- ============================================================
CREATE TABLE IF NOT EXISTS search_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  search_type TEXT DEFAULT 'general', -- general, users, posts, events
  searched_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_search_history_user ON search_history(user_id, searched_at DESC);

-- ============================================================
-- TRIGGER: Update posts count on profiles
-- ============================================================
CREATE OR REPLACE FUNCTION update_posts_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE profiles SET posts_count = posts_count + 1 WHERE id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE profiles SET posts_count = GREATEST(posts_count - 1, 0) WHERE id = OLD.user_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_post_change ON posts;
CREATE TRIGGER on_post_change
  AFTER INSERT OR DELETE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_posts_count();

-- ============================================================
-- TRIGGER: Update likes count on posts
-- ============================================================
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.post_id IS NOT NULL THEN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' AND OLD.post_id IS NOT NULL THEN
    UPDATE posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_like_change ON likes;
CREATE TRIGGER on_like_change
  AFTER INSERT OR DELETE ON likes
  FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- ============================================================
-- TRIGGER: Update comments count on posts
-- ============================================================
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_comment_change ON comments;
CREATE TRIGGER on_comment_change
  AFTER INSERT OR DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- PROFILES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- POSTS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Posts are viewable by everyone" ON posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = user_id);

-- POST IMAGES
ALTER TABLE post_images ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Post images viewable by everyone" ON post_images FOR SELECT USING (true);
CREATE POLICY "Post images insertable by post author" ON post_images FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM posts WHERE posts.id = post_id AND posts.user_id = auth.uid())
);

-- COMMENTS
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Comments viewable by everyone" ON comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can comment" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);

-- LIKES
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Likes viewable by everyone" ON likes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can like" ON likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove own likes" ON likes FOR DELETE USING (auth.uid() = user_id);

-- BOOKMARKS
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own bookmarks" ON bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can bookmark" ON bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove own bookmarks" ON bookmarks FOR DELETE USING (auth.uid() = user_id);

-- FOLLOWERS
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Followers viewable by everyone" ON followers FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON followers FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON followers FOR DELETE USING (auth.uid() = follower_id);

-- NOTIFICATIONS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own notifications" ON notifications FOR SELECT USING (auth.uid() = recipient_id);
CREATE POLICY "System can create notifications" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = recipient_id);

-- CONVERSATIONS
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view conversations" ON conversations FOR SELECT USING (
  EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = id AND user_id = auth.uid())
);
CREATE POLICY "Authenticated users can create conversations" ON conversations FOR INSERT WITH CHECK (true);

-- CONVERSATION PARTICIPANTS
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view participants" ON conversation_participants FOR SELECT USING (
  EXISTS (SELECT 1 FROM conversation_participants cp WHERE cp.conversation_id = conversation_id AND cp.user_id = auth.uid())
);
CREATE POLICY "Authenticated users can add participants" ON conversation_participants FOR INSERT WITH CHECK (true);

-- MESSAGES
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view messages" ON messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid())
);
CREATE POLICY "Participants can send messages" ON messages FOR INSERT WITH CHECK (
  auth.uid() = sender_id AND
  EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_id = messages.conversation_id AND user_id = auth.uid())
);

-- COMPANIES
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Companies viewable by everyone" ON companies FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create companies" ON companies FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update companies" ON companies FOR UPDATE USING (auth.uid() = created_by);

-- COMPANY MEMBERS
ALTER TABLE company_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Company members viewable by everyone" ON company_members FOR SELECT USING (true);
CREATE POLICY "Company admins can manage members" ON company_members FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM companies WHERE id = company_id AND created_by = auth.uid())
);

-- EVENTS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Events viewable by everyone" ON events FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create events" ON events FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update events" ON events FOR UPDATE USING (auth.uid() = created_by);

-- EVENT REGISTRATIONS
ALTER TABLE event_registrations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Registrations viewable by participant" ON event_registrations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can register" ON event_registrations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can cancel registration" ON event_registrations FOR DELETE USING (auth.uid() = user_id);

-- TEAMS
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Teams viewable by everyone" ON teams FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create teams" ON teams FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update teams" ON teams FOR UPDATE USING (auth.uid() = created_by);

-- TEAM MEMBERS
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Team members viewable by everyone" ON team_members FOR SELECT USING (true);
CREATE POLICY "Team leaders can manage members" ON team_members FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM teams WHERE id = team_id AND created_by = auth.uid())
  OR auth.uid() = user_id
);
CREATE POLICY "Members can leave or leaders can remove" ON team_members FOR DELETE USING (
  auth.uid() = user_id OR
  EXISTS (SELECT 1 FROM teams WHERE id = team_id AND created_by = auth.uid())
);

-- COMMUNITIES
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Communities viewable by everyone" ON communities FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create communities" ON communities FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update communities" ON communities FOR UPDATE USING (auth.uid() = created_by);

-- COMMUNITY MEMBERS
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Community members viewable by everyone" ON community_members FOR SELECT USING (true);
CREATE POLICY "Users can join communities" ON community_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave communities" ON community_members FOR DELETE USING (auth.uid() = user_id);

-- LEADERBOARDS
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leaderboards viewable by everyone" ON leaderboards FOR SELECT USING (true);

-- ACHIEVEMENTS
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Achievements viewable by everyone" ON achievements FOR SELECT USING (true);

-- PREMIUM SUBSCRIPTIONS
ALTER TABLE premium_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own subscription" ON premium_subscriptions FOR SELECT USING (auth.uid() = user_id);

-- VERIFICATION REQUESTS
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own requests" ON verification_requests FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can submit requests" ON verification_requests FOR INSERT WITH CHECK (auth.uid() = user_id);

-- USER SETTINGS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own settings" ON user_settings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own settings" ON user_settings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON user_settings FOR UPDATE USING (auth.uid() = user_id);

-- SEARCH HISTORY
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can see own search history" ON search_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can save search history" ON search_history FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own search history" ON search_history FOR DELETE USING (auth.uid() = user_id);
