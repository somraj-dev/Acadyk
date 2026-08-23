-- Migration V17: Seed Pre-Provisioned Institutional Users and Real Database Posts

-- 1. Insert Pre-Provisioned Users
INSERT INTO users (
    id,
    email,
    college_email,
    enrollment_number,
    degree,
    branch,
    department,
    joining_year,
    role,
    account_status,
    is_active,
    is_email_verified,
    profile_completed,
    auth_provider,
    created_at,
    updated_at
) VALUES 
(
    'a1111111-1111-1111-1111-111111111111',
    '25am1ab4@mitsgwl.ac.in',
    '25am1ab4@mitsgwl.ac.in',
    'BTAM2501004',
    'B.Tech',
    'Artificial Intelligence and Machine Learning',
    'Department of Artificial Intelligence & Data Science',
    2025,
    'STUDENT'::user_role_enum,
    'ACTIVE',
    true,
    true,
    true,
    'FIREBASE_GOOGLE',
    NOW() - INTERVAL '30 days',
    NOW()
),
(
    'b2222222-2222-2222-2222-222222222222',
    '22cs1001@mitsgwl.ac.in',
    '22cs1001@mitsgwl.ac.in',
    '0901CS221001',
    'B.Tech',
    'Computer Science & Engineering',
    'Department of Computer Science & Engineering',
    2022,
    'STUDENT'::user_role_enum,
    'ACTIVE',
    true,
    true,
    true,
    'FIREBASE_GOOGLE',
    NOW() - INTERVAL '60 days',
    NOW()
)
ON CONFLICT (email) DO UPDATE SET
    account_status = 'ACTIVE',
    is_active = true,
    college_email = EXCLUDED.college_email,
    enrollment_number = EXCLUDED.enrollment_number;

-- 2. Insert User Profiles
INSERT INTO profiles (
    id,
    user_id,
    username,
    full_name,
    headline,
    bio,
    college_name,
    major,
    graduation_year,
    location,
    is_private,
    followers_count,
    following_count,
    connections_count,
    created_at,
    updated_at
) VALUES 
(
    'a1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    '25am1ab4',
    'BTAM2501004 ABHAY GUPTA',
    'AI Systems & Software Development',
    'B.Tech in Artificial Intelligence and Machine Learning at Madhav Institute of Technology & Science (MITS Gwalior). Passionate about systems engineering and AI-assisted tooling.',
    'Madhav Institute of Technology & Science, Gwalior',
    'Artificial Intelligence and Machine Learning',
    2029,
    'Gwalior, Madhya Pradesh, India',
    false,
    1,
    0,
    0,
    NOW() - INTERVAL '30 days',
    NOW()
),
(
    'b2222222-2222-2222-2222-222222222222',
    'b2222222-2222-2222-2222-222222222222',
    '0901cs221001',
    'Rahul Sharma',
    'Full-Stack Developer & Distributed Systems Enthusiast',
    'Final year Computer Science & Engineering student at MITS Gwalior. Building scalable microservices and mobile applications.',
    'Madhav Institute of Technology & Science, Gwalior',
    'Computer Science & Engineering',
    2026,
    'Gwalior, Madhya Pradesh, India',
    false,
    0,
    1,
    0,
    NOW() - INTERVAL '60 days',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    headline = EXCLUDED.headline,
    bio = EXCLUDED.bio;

-- 3. Insert Real Realistic Campus & Technology Posts for Abhay
INSERT INTO posts (
    id,
    author_id,
    content,
    post_type,
    visibility,
    likes_count,
    comments_count,
    shares_count,
    created_at,
    updated_at
) VALUES
(
    'c3333333-3333-3333-3333-333333333300',
    'a1111111-1111-1111-1111-111111111111',
    'hiee',
    'text',
    'public',
    1,
    0,
    0,
    NOW() - INTERVAL '5 minutes',
    NOW() - INTERVAL '5 minutes'
),
(
    'c3333333-3333-3333-3333-333333333301',
    'a1111111-1111-1111-1111-111111111111',
    'AI is moving incredibly fast. The interesting part isn''t just generating code anymore — it''s understanding how to verify, test, and actually use what AI produces.',
    'tech',
    'public',
    3,
    1,
    0,
    NOW() - INTERVAL '25 minutes',
    NOW() - INTERVAL '25 minutes'
),
(
    'c3333333-3333-3333-3333-333333333302',
    'a1111111-1111-1111-1111-111111111111',
    'Working on a few ideas around campus technology and student collaboration. There are a lot of everyday problems that could be solved with simple, well-designed software.',
    'innovation',
    'public',
    5,
    0,
    0,
    NOW() - INTERVAL '1 hour',
    NOW() - INTERVAL '1 hour'
),
(
    'c3333333-3333-3333-3333-333333333303',
    'a1111111-1111-1111-1111-111111111111',
    'Spent some time working on backend architecture today. Keeping authentication, APIs, database operations, and the mobile client separated makes the entire system much easier to maintain.',
    'engineering',
    'public',
    7,
    0,
    0,
    NOW() - INTERVAL '3 hours',
    NOW() - INTERVAL '3 hours'
),
(
    'c3333333-3333-3333-3333-333333333304',
    'a1111111-1111-1111-1111-111111111111',
    'Software projects become much more interesting when they solve an actual problem instead of just being another demo application.',
    'campus',
    'public',
    4,
    0,
    0,
    NOW() - INTERVAL '6 hours',
    NOW() - INTERVAL '6 hours'
),
(
    'c3333333-3333-3333-3333-333333333305',
    'a1111111-1111-1111-1111-111111111111',
    'Exploring how students can collaborate on projects, startups, events, and technical ideas through a common campus platform.',
    'collaboration',
    'public',
    6,
    1,
    0,
    NOW() - INTERVAL '12 hours',
    NOW() - INTERVAL '12 hours'
),
(
    'c3333333-3333-3333-3333-333333333306',
    'a1111111-1111-1111-1111-111111111111',
    'Building something useful usually takes more debugging than expected. The important part is making sure the final system is reliable, not just making the first version work.',
    'development',
    'public',
    2,
    0,
    0,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
),
(
    'c3333333-3333-3333-3333-333333333307',
    'a1111111-1111-1111-1111-111111111111',
    'Interested in seeing how AI, cloud infrastructure, and mobile applications can come together to build better tools for students.',
    'cloud',
    'public',
    8,
    0,
    0,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days'
),
(
    'c3333333-3333-3333-3333-333333333308',
    'a1111111-1111-1111-1111-111111111111',
    'Campus communities have a lot of talented people. A good platform should make it easier to discover people, projects, clubs, events, and ideas.',
    'community',
    'public',
    9,
    1,
    0,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days'
),
(
    'c3333333-3333-3333-3333-333333333309',
    'a1111111-1111-1111-1111-111111111111',
    'Testing the Acadyk social feed with real database-backed content. Posts, comments, reactions, and follows should all survive application restarts.',
    'testing',
    'public',
    5,
    0,
    0,
    NOW() - INTERVAL '4 days',
    NOW() - INTERVAL '4 days'
),
(
    'c3333333-3333-3333-3333-333333333310',
    'a1111111-1111-1111-1111-111111111111',
    'Looking forward to building and testing more technology projects with the MITS Gwalior community.',
    'mits',
    'public',
    11,
    0,
    0,
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '5 days'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    post_type = EXCLUDED.post_type,
    likes_count = EXCLUDED.likes_count,
    comments_count = EXCLUDED.comments_count;

-- 4. Insert Real Database Comments
INSERT INTO comments (
    id,
    post_id,
    author_id,
    content,
    likes_count,
    created_at,
    updated_at
) VALUES 
(
    'd4444444-4444-4444-4444-444444444401',
    'c3333333-3333-3333-3333-333333333301',
    'b2222222-2222-2222-2222-222222222222',
    'Agreed. The verification part is probably the most important.',
    2,
    NOW() - INTERVAL '20 minutes',
    NOW() - INTERVAL '20 minutes'
),
(
    'd4444444-4444-4444-4444-444444444402',
    'c3333333-3333-3333-3333-333333333305',
    'b2222222-2222-2222-2222-222222222222',
    'Would be great to have project collaboration features for this.',
    3,
    NOW() - INTERVAL '10 hours',
    NOW() - INTERVAL '10 hours'
),
(
    'd4444444-4444-4444-4444-444444444403',
    'c3333333-3333-3333-3333-333333333308',
    'b2222222-2222-2222-2222-222222222222',
    'Excited for this! Looking forward to collaborating across departments.',
    1,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

-- 5. Insert Real Database Reactions
INSERT INTO post_reactions (
    id,
    post_id,
    user_id,
    reaction_type,
    created_at
) VALUES 
(
    'e5555555-5555-5555-5555-555555555500',
    'c3333333-3333-3333-3333-333333333300',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '4 minutes'
),
(
    'e5555555-5555-5555-5555-555555555501',
    'c3333333-3333-3333-3333-333333333301',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '22 minutes'
),
(
    'e5555555-5555-5555-5555-555555555502',
    'c3333333-3333-3333-3333-333333333303',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '2 hours'
),
(
    'e5555555-5555-5555-5555-555555555503',
    'c3333333-3333-3333-3333-333333333305',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '11 hours'
),
(
    'e5555555-5555-5555-5555-555555555504',
    'c3333333-3333-3333-3333-333333333308',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '2 days'
),
(
    'e5555555-5555-5555-5555-555555555505',
    'c3333333-3333-3333-3333-333333333310',
    'b2222222-2222-2222-2222-222222222222',
    'LIKE',
    NOW() - INTERVAL '4 days'
)
ON CONFLICT (id) DO NOTHING;

-- 6. Insert Real Database Follows
INSERT INTO follows (
    id,
    follower_id,
    following_id,
    created_at
) VALUES (
    'f6666666-6666-6666-6666-666666666601',
    'b2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '5 days'
)
ON CONFLICT (id) DO NOTHING;
