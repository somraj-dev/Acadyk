-- Migration 000010: Events Table
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organizer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT DEFAULT 'Hackathon',
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  location TEXT,
  banner_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
