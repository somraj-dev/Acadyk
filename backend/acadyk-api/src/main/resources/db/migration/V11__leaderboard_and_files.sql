-- =============================================================================
-- V11__leaderboard_and_files.sql
-- Academic ranking points and managed object storage references
-- =============================================================================

CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    category VARCHAR(100) DEFAULT 'Global Impact' NOT NULL,
    score INT DEFAULT 0 NOT NULL,
    rank INT DEFAULT 1 NOT NULL,
    period VARCHAR(32) DEFAULT 'ALL_TIME' NOT NULL,
    snapshot_date DATE DEFAULT CURRENT_DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uq_leaderboard_entry UNIQUE (profile_id, category, period, snapshot_date)
);

CREATE TABLE IF NOT EXISTS files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    bucket_name VARCHAR(128) NOT NULL,
    file_key VARCHAR(512) NOT NULL UNIQUE,
    file_name VARCHAR(255) NOT NULL,
    content_type VARCHAR(128) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    is_public BOOLEAN DEFAULT TRUE NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
