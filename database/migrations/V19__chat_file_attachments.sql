-- =============================================================================
-- V19__chat_file_attachments.sql
-- Adds file attachment metadata columns to messages table for WhatsApp-style
-- document/file sharing within chat conversations.
-- Also extends message_type_enum with DOCUMENT and VIDEO types.
-- =============================================================================

-- Extend message_type_enum with new file-related types
ALTER TYPE message_type_enum ADD VALUE IF NOT EXISTS 'DOCUMENT';
ALTER TYPE message_type_enum ADD VALUE IF NOT EXISTS 'VIDEO';

-- Add file attachment metadata columns to messages table
ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_name VARCHAR(500) NULL;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS file_size_bytes BIGINT NULL;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS mime_type VARCHAR(100) NULL;
ALTER TABLE messages ADD COLUMN IF NOT EXISTS thumbnail_url TEXT NULL;

-- Index for efficient file message queries (e.g., "show all files shared in this conversation")
CREATE INDEX IF NOT EXISTS idx_messages_conversation_file
    ON messages (conversation_id, message_type)
    WHERE message_type IN ('FILE', 'IMAGE', 'DOCUMENT', 'VIDEO')
    AND deleted_at IS NULL;
