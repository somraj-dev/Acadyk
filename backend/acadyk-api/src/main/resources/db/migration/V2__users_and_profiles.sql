-- =============================================================================
-- V2__users_and_profiles.sql
-- Core users & normalized profile records
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(128) NOT NULL UNIQUE,
    email CITEXT NOT NULL UNIQUE,
    role user_role_enum DEFAULT 'STUDENT' NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_email_verified BOOLEAN DEFAULT FALSE NOT NULL,
    last_sign_in_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    username CITEXT NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    headline VARCHAR(255),
    bio TEXT,
    college_name VARCHAR(255),
    major VARCHAR(255),
    graduation_year INT,
    location VARCHAR(255),
    profile_photo_url TEXT,
    cover_photo_url TEXT,
    status_emoji VARCHAR(16),
    status_text VARCHAR(255),
    is_private BOOLEAN DEFAULT FALSE NOT NULL,
    followers_count INT DEFAULT 0 NOT NULL,
    following_count INT DEFAULT 0 NOT NULL,
    connections_count INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE NULL,
    CONSTRAINT chk_graduation_year CHECK (graduation_year IS NULL OR (graduation_year >= 1970 AND graduation_year <= 2100))
);
