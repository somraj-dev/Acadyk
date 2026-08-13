# Acadyk — Enterprise Monorepo

Acadyk is a next-generation academic, professional, and career discovery network built with **Flutter** and **Supabase**.

## Monorepo Architecture

```
Acadyk/
├── apps/
│   └── mobile/          # Flutter Mobile Application
├── backend/
│   └── supabase/        # Database Migrations, RLS Policies, Edge Functions
├── infra/               # Deployment & Monitoring Configurations
├── docs/                # Architecture, DB Schema, & API Documentation
└── scripts/             # Shell Automation Scripts
```

## Getting Started

1. Bootstrap dependencies:
   ```bash
   make bootstrap
   ```

2. Run static analysis:
   ```bash
   make lint
   ```

3. Run mobile application:
   ```bash
   cd apps/mobile && flutter run
   ```
