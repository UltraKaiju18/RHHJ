# Database

This folder contains all database design, migration, and configuration files for the RHHJ Supabase PostgreSQL database.

## Sub-folders

| Folder | Purpose |
|--------|---------|
| [`supabase/`](supabase/) | Supabase project configuration (auth, storage, edge functions, Row Level Security policies) |
| [`migrations/`](migrations/) | Versioned SQL migration scripts |
| [`schemas/`](schemas/) | Entity-relationship diagrams and schema documentation |
| [`seed-data/`](seed-data/) | Sample and reference data SQL scripts for development and testing |

## Technology: Supabase

[Supabase](https://supabase.com) provides a hosted PostgreSQL database with:
- **REST & GraphQL APIs** — auto-generated from your schema
- **Row Level Security (RLS)** — fine-grained access control
- **Realtime** — live data subscriptions
- **Auth** — built-in user authentication
- **Storage** — file/document storage

## Setup Instructions

1. Create a new project at [app.supabase.com](https://app.supabase.com).
2. Copy your project URL and anon/service-role API keys to a local `.env` file (never commit this file).
3. Run migration scripts from [`migrations/`](migrations/) in order against your Supabase project.
4. Load reference data from [`seed-data/`](seed-data/) if needed.

## Migration Naming Convention

Migration files should be numbered sequentially:

```
migrations/
├── 001_create_patients_table.sql
├── 002_create_visits_table.sql
├── 003_create_medications_table.sql
└── ...
```
