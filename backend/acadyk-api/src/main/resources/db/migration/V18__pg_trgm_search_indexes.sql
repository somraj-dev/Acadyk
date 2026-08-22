-- =============================================================================
-- V18__pg_trgm_search_indexes.sql
-- Enable pg_trgm extension and create GIN trigram indexes for full-text search
-- Replaces Elasticsearch-based search with PostgreSQL-native trigram search
-- NON-DESTRUCTIVE: No tables are dropped, truncated, or modified
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Profile full-text search indexes (GIN trigram)
CREATE INDEX IF NOT EXISTS idx_profiles_fullname_trgm
    ON profiles USING gin (full_name gin_trgm_ops)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_username_trgm
    ON profiles USING gin (username gin_trgm_ops)
    WHERE deleted_at IS NULL;

-- User identity search indexes (GIN trigram)
CREATE INDEX IF NOT EXISTS idx_users_email_trgm
    ON users USING gin (email gin_trgm_ops)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_users_college_email_trgm
    ON users USING gin (college_email gin_trgm_ops)
    WHERE deleted_at IS NULL AND college_email IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_enrollment_trgm
    ON users USING gin (enrollment_number gin_trgm_ops)
    WHERE deleted_at IS NULL AND enrollment_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_branch_trgm
    ON users USING gin (branch gin_trgm_ops)
    WHERE deleted_at IS NULL AND branch IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_department_trgm
    ON users USING gin (department gin_trgm_ops)
    WHERE deleted_at IS NULL AND department IS NOT NULL;
