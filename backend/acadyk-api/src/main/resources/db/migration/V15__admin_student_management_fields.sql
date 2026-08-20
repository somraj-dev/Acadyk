-- =============================================================================
-- V15__admin_student_management_fields.sql
-- Non-destructive extension for College Admin Student & Faculty Management
-- =============================================================================

-- Extend users table with additional institutional & personal details
ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(32);
ALTER TABLE users ADD COLUMN IF NOT EXISTS employee_id VARCHAR(64);
ALTER TABLE users ADD COLUMN IF NOT EXISTS father_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS father_mobile VARCHAR(32);
ALTER TABLE users ADD COLUMN IF NOT EXISTS current_address TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS admission_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS registration_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS designation VARCHAR(128);

-- Administrative suspension audit fields
ALTER TABLE users ADD COLUMN IF NOT EXISTS suspension_reason TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS suspended_by VARCHAR(255);

-- Extend profiles table if needed for student phone & department
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS department VARCHAR(255);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone VARCHAR(32);

-- Additional indexes for fast admin querying
CREATE INDEX IF NOT EXISTS idx_users_employee_id ON users(employee_id);
CREATE INDEX IF NOT EXISTS idx_users_department ON users(department);
CREATE INDEX IF NOT EXISTS idx_users_account_status ON users(account_status);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
