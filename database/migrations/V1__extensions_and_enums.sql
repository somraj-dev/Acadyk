-- =============================================================================
-- V1__extensions_and_enums.sql
-- Enables core PostgreSQL extensions and defines standard schema enums
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Standard User & Role Enums
CREATE TYPE user_role_enum AS ENUM (
    'STUDENT',
    'FACULTY',
    'COLLEGE_ADMIN',
    'COMPANY',
    'MODERATOR',
    'SUPER_ADMIN'
);

-- Connection Status
CREATE TYPE connection_status_enum AS ENUM (
    'PENDING',
    'ACCEPTED',
    'REJECTED',
    'BLOCKED'
);

-- Opportunity Types
CREATE TYPE opportunity_type_enum AS ENUM (
    'INTERNSHIP',
    'FULL_TIME',
    'PART_TIME',
    'HACKATHON',
    'RESEARCH',
    'SCHOLARSHIP'
);

-- Application Status
CREATE TYPE application_status_enum AS ENUM (
    'APPLIED',
    'REVIEWING',
    'INTERVIEW_SCHEDULED',
    'ACCEPTED',
    'REJECTED',
    'WITHDRAWN'
);

-- Message Type
CREATE TYPE message_type_enum AS ENUM (
    'TEXT',
    'IMAGE',
    'FILE',
    'AUDIO',
    'SYSTEM'
);
