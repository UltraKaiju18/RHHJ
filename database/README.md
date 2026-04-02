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
3. Apply migrations using one of the methods below.
4. Load reference data from [`seed-data/`](seed-data/) if needed.

## Applying Migrations

### Option A — Supabase CLI (recommended)

```bash
# Link CLI to your Supabase project (once per machine)
supabase link --project-ref <your-project-ref>

# Push all pending migrations to the linked remote project
supabase db push
```

### Option B — Supabase SQL Editor (manual)

1. Open your project at [app.supabase.com](https://app.supabase.com).
2. Navigate to **SQL Editor**.
3. Open each file in `migrations/` in alphabetical order.
4. Paste the SQL content into the editor and click **Run**.

> Run migrations in filename order (alphabetical = chronological because files are
> timestamped `YYYYMMDDHHMMSS_description.sql`).

## Migration Naming Convention

Migration files use a UTC timestamp prefix so they sort chronologically:

```
migrations/
├── 20260402000000_initial_core_schema.sql
├── 20260501120000_add_rls_policies.sql
└── ...
```
