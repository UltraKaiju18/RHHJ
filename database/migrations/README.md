# Database Migrations

This folder contains versioned SQL migration scripts for the RHHJ Supabase PostgreSQL database.

## Naming Convention

Files must be named with a zero-padded sequence number followed by a descriptive name:

```
001_create_patients_table.sql
002_create_visits_table.sql
003_create_medications_table.sql
```

## Running Migrations

### Using Supabase CLI (recommended)

```bash
# Push all pending migrations to the linked remote project
supabase db push
```

### Manual execution

Paste the SQL content of each migration file into the Supabase **SQL Editor** at [app.supabase.com](https://app.supabase.com), running them in sequential order.

## Initial Schema (Placeholder)

The first migration scripts will be created once the data structure documents in
[`../../docs/data-structures/`](../../docs/data-structures/) have been reviewed.

Anticipated core tables include:

- `patients` — patient demographics and registration
- `visits` — home visit records
- `assessments` — clinical assessments per visit
- `medications` — medication records
- `care_workers` — care worker profiles
- `locations` — villages and catchment areas
