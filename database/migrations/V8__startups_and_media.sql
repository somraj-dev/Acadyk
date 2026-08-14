-- =============================================================================
-- V8__startups_and_media.sql
-- Campus startups, venture showcases, team rosters, and media portfolios
-- =============================================================================

CREATE TABLE IF NOT EXISTS startups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    founder_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug CITEXT NOT NULL UNIQUE,
    pitch VARCHAR(500) NOT NULL,
    description TEXT,
    stage VARCHAR(50) DEFAULT 'Idea' NOT NULL,
    industry VARCHAR(100) NOT NULL,
    website_url TEXT,
    logo_url TEXT,
    banner_url TEXT,
    team_size INT DEFAULT 1 NOT NULL,
    funding_raised VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TABLE IF NOT EXISTS startup_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    startup_id UUID NOT NULL REFERENCES startups(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role_title VARCHAR(255) DEFAULT 'Co-founder / Member' NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uq_startup_member UNIQUE (startup_id, profile_id)
);

CREATE TABLE IF NOT EXISTS startup_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    startup_id UUID NOT NULL REFERENCES startups(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type VARCHAR(50) DEFAULT 'image' NOT NULL,
    caption VARCHAR(255),
    position INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
