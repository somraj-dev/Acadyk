-- =============================================================================
-- V13__indexes_and_performance.sql
-- High-throughput B-Tree & composite indexes for query access patterns
-- =============================================================================

-- 1. Users & Identity Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);

-- 2. Profile Discovery Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_college ON profiles(college_name) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- 3. Experience & Portfolio Indexes
CREATE INDEX IF NOT EXISTS idx_education_profile ON education(profile_id);
CREATE INDEX IF NOT EXISTS idx_experiences_profile ON experiences(profile_id);
CREATE INDEX IF NOT EXISTS idx_certificates_profile ON certificates(profile_id);
CREATE INDEX IF NOT EXISTS idx_achievements_profile ON achievements(profile_id);

-- 4. Social Feed & Engagement Indexes
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_post_media_post ON post_media(post_id, position ASC);
CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id, created_at ASC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_post_reactions_post ON post_reactions(post_id);

-- 5. Connections & Follower Graph Indexes
CREATE INDEX IF NOT EXISTS idx_connections_user_a ON connections(user_a_id);
CREATE INDEX IF NOT EXISTS idx_connections_user_b ON connections(user_b_id);
CREATE INDEX IF NOT EXISTS idx_conn_req_recipient_status ON connection_requests(recipient_id, status);
CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);

-- 6. Communities & Clubs Indexes
CREATE INDEX IF NOT EXISTS idx_communities_category ON communities(category) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_community_members_profile ON community_members(profile_id);
CREATE INDEX IF NOT EXISTS idx_clubs_college ON clubs(college_name) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_club_members_profile ON club_members(profile_id);

-- 7. Events & Opportunities Indexes
CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_opportunities_deadline ON opportunities(deadline DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_opp_applications_profile ON opportunity_applications(profile_id);

-- 8. Startups Indexes
CREATE INDEX IF NOT EXISTS idx_startups_stage ON startups(stage) WHERE deleted_at IS NULL;

-- 9. Realtime Chat & Messaging Indexes
CREATE INDEX IF NOT EXISTS idx_conversations_last_msg ON conversations(last_message_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_conv_members_profile ON conversation_members(profile_id);
CREATE INDEX IF NOT EXISTS idx_messages_conv_created ON messages(conversation_id, created_at ASC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_message_reads_profile ON message_reads(profile_id);

-- 10. Notification Feed Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_created ON notifications(recipient_id, is_read, created_at DESC);

-- 11. Leaderboard & Storage Indexes
CREATE INDEX IF NOT EXISTS idx_leaderboard_category_score ON leaderboard_entries(category, period, score DESC);
CREATE INDEX IF NOT EXISTS idx_files_uploader ON files(uploader_id);

-- 12. Security Audit Indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_created ON audit_logs(actor_id, created_at DESC);
