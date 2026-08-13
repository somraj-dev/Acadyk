-- Migration 000011: Opportunities Table
CREATE TABLE IF NOT EXISTS opportunities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  poster_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  company_name TEXT NOT NULL,
  type TEXT DEFAULT 'Internship',
  location TEXT,
  stipend TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
