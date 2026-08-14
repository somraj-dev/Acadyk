-- =============================================================================
-- V12__audit_logs.sql
-- Security compliance and immutable audit trail records
-- =============================================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID,
    actor_email VARCHAR(255),
    action VARCHAR(128) NOT NULL,
    entity_type VARCHAR(64),
    entity_id UUID,
    ip_address VARCHAR(64) NOT NULL,
    user_agent TEXT,
    status VARCHAR(32) DEFAULT 'SUCCESS' NOT NULL,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
