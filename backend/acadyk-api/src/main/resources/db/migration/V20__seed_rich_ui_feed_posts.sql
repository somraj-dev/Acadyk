-- =============================================================================
-- Migration V20: Seed Rich UI Dummy Posts for Feed Testing
-- Includes WhatsApp-style document cards, hackathon victory images, and polls
-- =============================================================================

-- Ensure MITS Official profile exists for official notices
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
    'c1111111-1111-1111-1111-111111111111',
    'academic.dean@mitsgwl.ac.in',
    'academic.dean@mitsgwl.ac.in',
    'MITS-ADMIN-01',
    'Faculty',
    'Academic Affairs',
    'Office of the Dean',
    2020,
    'FACULTY'::user_role_enum,
    'ACTIVE',
    true,
    true,
    true,
    'FIREBASE_GOOGLE',
    NOW() - INTERVAL '90 days',
    NOW()
)
ON CONFLICT (email) DO UPDATE SET
    account_status = 'ACTIVE',
    is_active = true;

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
    'c1111111-1111-1111-1111-111111111111',
    'c1111111-1111-1111-1111-111111111111',
    'mits_academics',
    'MITS Academic Administration',
    'Office of the Dean (Academic Affairs) • Official Circulars',
    'Official academic notices, examination schedules, syllabus revisions, and campus regulations for Madhav Institute of Technology & Science, Gwalior.',
    'Madhav Institute of Technology & Science, Gwalior',
    'Academic Affairs',
    2026,
    'Gwalior, Madhya Pradesh, India',
    false,
    1420,
    12,
    450,
    NOW() - INTERVAL '90 days',
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    headline = EXCLUDED.headline;

-- 1. Official Academic Notification Post with PDF Document Attachment
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
    'd4444444-4444-4444-4444-444444444401',
    'c1111111-1111-1111-1111-111111111111',
    '📢 NOTICE: End-Semester Examination Schedule for Autumn 2026 has been officially released. All B.Tech, M.Tech, and MCA students must download and review their subject codes, shift timings, and respective examination halls. Hall tickets will be issued starting Monday.',
    'notification',
    'public',
    154,
    23,
    45,
    NOW() - INTERVAL '15 minutes',
    NOW() - INTERVAL '15 minutes'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

INSERT INTO post_media (
    id,
    post_id,
    media_url,
    media_type,
    position,
    created_at
) VALUES 
(
    'e5555555-5555-5555-5555-555555555501',
    'd4444444-4444-4444-4444-444444444401',
    'https://raw.githubusercontent.com/mozilla/pdf.js/master/examples/learning/helloworld.pdf',
    'document',
    0,
    NOW() - INTERVAL '15 minutes'
)
ON CONFLICT (id) DO NOTHING;

-- 2. Student Study Materials Post with PDF Revision Notes
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
    'd4444444-4444-4444-4444-444444444402',
    'a1111111-1111-1111-1111-111111111111',
    'Hey everyone! 👋 As promised, here are the complete revision notes for Distributed Systems & Cloud Architecture (Units 1 to 5). Includes detailed diagrams on Raft consensus, CAP theorem trade-offs, and microservices caching patterns. Good luck with the mid-term test tomorrow! 🚀📚',
    'student',
    'public',
    238,
    41,
    62,
    NOW() - INTERVAL '1 hour',
    NOW() - INTERVAL '1 hour'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

INSERT INTO post_media (
    id,
    post_id,
    media_url,
    media_type,
    position,
    created_at
) VALUES 
(
    'e5555555-5555-5555-5555-555555555502',
    'd4444444-4444-4444-4444-444444444402',
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'document',
    0,
    NOW() - INTERVAL '1 hour'
)
ON CONFLICT (id) DO NOTHING;

-- 3. Campus Hackathon Victory Post with Event Image
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
    'd4444444-4444-4444-4444-444444444403',
    'b2222222-2222-2222-2222-222222222222',
    'Huge congratulations to Team NeuralRoots from MITS for bagging 1st Place at Smart India Hackathon 2026! 🚀🏆 Built an automated crop-disease detection UAV drone operating with edge-computed quantized vision models in under 36 hours. Extremely proud of our campus innovators!',
    'student',
    'public',
    512,
    67,
    120,
    NOW() - INTERVAL '3 hours',
    NOW() - INTERVAL '3 hours'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

INSERT INTO post_media (
    id,
    post_id,
    media_url,
    media_type,
    position,
    created_at
) VALUES 
(
    'e5555555-5555-5555-5555-555555555503',
    'd4444444-4444-4444-4444-444444444403',
    'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80',
    'image',
    0,
    NOW() - INTERVAL '3 hours'
)
ON CONFLICT (id) DO NOTHING;

-- 4. Interactive Campus Workshop Poll Post
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
    'd4444444-4444-4444-4444-444444444404',
    'b2222222-2222-2222-2222-222222222222',
    '📊 TechFest 2026 Workshop Track Poll! We are partnering with top engineering leads to conduct hands-on masterclasses next month. Which domain would you like us to prioritize?',
    'poll',
    'public',
    189,
    32,
    15,
    NOW() - INTERVAL '5 hours',
    NOW() - INTERVAL '5 hours'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

-- 5. Startup Incubation Announcement Post with Document
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
    'd4444444-4444-4444-4444-444444444405',
    'a1111111-1111-1111-1111-111111111111',
    'Thrilled to share that AeroDrone Systems has officially received seed incubation and lab prototyping support from MITS Innovation & Incubation Centre (IIC)! 🛸🏭 We are looking for 2 embedded C++ interns and 1 Flutter developer to join our core team. Attached is the project brief & open roles description. Apply through the Opportunities tab!',
    'student',
    'public',
    315,
    54,
    89,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
)
ON CONFLICT (id) DO UPDATE SET
    content = EXCLUDED.content,
    likes_count = EXCLUDED.likes_count;

INSERT INTO post_media (
    id,
    post_id,
    media_url,
    media_type,
    position,
    created_at
) VALUES 
(
    'e5555555-5555-5555-5555-555555555505',
    'd4444444-4444-4444-4444-444444444405',
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'document',
    0,
    NOW() - INTERVAL '1 day'
)
ON CONFLICT (id) DO NOTHING;
