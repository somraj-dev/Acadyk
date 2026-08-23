-- =============================================================================
-- V16__allow_nullable_firebase_uid_and_optimizations.sql
-- Enables pre-provisioning of institutional accounts prior to first Firebase login
-- and adds performance indexes for high-throughput admin queries and search
-- =============================================================================

-- 1. Allow firebase_uid to be NULL when an institutional user is pre-provisioned by Admin
ALTER TABLE users ALTER COLUMN firebase_uid DROP NOT NULL;

-- 2. Ensure case-insensitive unique indexes on normalized emails if not already present
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_normalized_email ON users (LOWER(email));
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_normalized_college_email ON users (LOWER(college_email)) WHERE college_email IS NOT NULL;

-- 3. High performance composite and query filtering indexes for Admin User Management
CREATE INDEX IF NOT EXISTS idx_users_search_composite ON users (role, account_status, degree, branch) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users (LOWER(email)) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_college_email_lower ON users (LOWER(college_email)) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_created_at_desc ON users (created_at DESC) WHERE deleted_at IS NULL;
