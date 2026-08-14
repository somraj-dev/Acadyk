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

4. Run web application on localhost (for manual verification):
   ```bash
   make web
   # or
   cd apps/mobile && flutter run -d web-server --web-port 8080 --web-hostname localhost
   ```
   Open [http://localhost:8080](http://localhost:8080) in your browser.

