-- =============================================================================
-- V14__auth_identity_and_audit.sql
-- Enhanced Student Identity Provisioning & Authentication Audit Trail
-- =============================================================================

-- 1. Extend users table with institutional college identity fields
ALTER TABLE users ADD COLUMN IF NOT EXISTS college_email CITEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS enrollment_number VARCHAR(64);
ALTER TABLE users ADD COLUMN IF NOT EXISTS degree VARCHAR(64) DEFAULT 'B.Tech';
ALTER TABLE users ADD COLUMN IF NOT EXISTS branch VARCHAR(128);
ALTER TABLE users ADD COLUMN IF NOT EXISTS joining_year INT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS account_status VARCHAR(32) DEFAULT 'ACTIVE';
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(64) DEFAULT 'FIREBASE_GOOGLE';
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_login_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP WITH TIME ZONE;

-- Add unique constraints safely if not present
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_users_college_email') THEN
        ALTER TABLE users ADD CONSTRAINT uq_users_college_email UNIQUE (college_email);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uq_users_enrollment_number') THEN
        ALTER TABLE users ADD CONSTRAINT uq_users_enrollment_number UNIQUE (enrollment_number);
    END IF;
END $$;

-- 2. Create dedicated authentication audit logs table
CREATE TABLE IF NOT EXISTS auth_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(128),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    email VARCHAR(255) NOT NULL,
    event_type VARCHAR(64) NOT NULL,
    success BOOLEAN NOT NULL,
    failure_reason TEXT,
    device_info TEXT,
    app_version VARCHAR(32),
    ip_address VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 3. Indexes for fast query lookup and security investigations
CREATE INDEX IF NOT EXISTS idx_users_enrollment ON users(enrollment_number);
CREATE INDEX IF NOT EXISTS idx_users_college_email ON users(college_email);
CREATE INDEX IF NOT EXISTS idx_auth_audit_uid ON auth_audit_logs(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_auth_audit_email ON auth_audit_logs(email);
CREATE INDEX IF NOT EXISTS idx_auth_audit_created ON auth_audit_logs(created_at DESC);
