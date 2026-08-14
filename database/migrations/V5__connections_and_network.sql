-- =============================================================================
-- V5__connections_and_network.sql
-- Connection graphs, pending requests, and asymmetric follower systems
-- =============================================================================

CREATE TABLE IF NOT EXISTS connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    user_b_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    connected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_no_self_connection CHECK (user_a_id != user_b_id),
    CONSTRAINT uq_connection_pair UNIQUE (user_a_id, user_b_id)
);

CREATE TABLE IF NOT EXISTS connection_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status connection_status_enum DEFAULT 'PENDING' NOT NULL,
    message VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    responded_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_no_self_request CHECK (sender_id != recipient_id),
    CONSTRAINT uq_sender_recipient UNIQUE (sender_id, recipient_id)
);

CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_no_self_follow CHECK (follower_id != following_id),
    CONSTRAINT uq_follower_following UNIQUE (follower_id, following_id)
);
