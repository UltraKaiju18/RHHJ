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

## Migrations

| File | Description |
|------|-------------|
| `20260402000000_initial_core_schema.sql` | Initial core schema: teams, users, locations, households, persons, all clinical event tables, RIP uniqueness constraint, and performance indexes. |

## Core tables created by the initial migration

| Table | Purpose |
|-------|---------|
| `team` | Field teams that hold a shared caseload |
| `user_profile` | Supabase Auth user metadata (keyed by `auth.users.id`) |
| `location` | Administrative hierarchy (district → village) |
| `household` | Household record; used for sync scoping and household data |
| `household_member` | Links persons to households |
| `team_household_assignment` | Assigns households (and their members) to a team |
| `person` | Person registry; `idn` is immutable and assigned at first screening |
| `screening_event` | One row per screening attempt |
| `program_episode` | Explicit enrolment episode per person |
| `patient_status_event` | Status timeline (enrolled, remission, ltf, rip, …) |
| `care_visit` | Home/facility/phone visit records (adult and child) |
| `consultation_event` | Clinical consultations |
| `treatment_support_event` | Transport, fees, and other treatment support events |
| `household_assessment_event` | Periodic household-level assessments |
| `household_support_event` | Support delivered at the household level |
