# Seed Data

This folder contains SQL scripts to populate the RHHJ database with reference and sample data for development and testing.

## Files

| File | Description |
|------|-------------|
| `reference_locations.sql` | Uganda administrative locations (districts, parishes, villages) |
| `reference_medications.sql` | Standard medication list used by RHHJ |
| `sample_patients.sql` | Anonymised sample patient records for testing |
| `sample_visits.sql` | Sample home visit records for testing |

## Usage

Run seed scripts in the Supabase SQL Editor or via the Supabase CLI after applying all migrations:

```bash
# Via Supabase CLI (from repository root)
supabase db reset   # resets local DB and re-runs all migrations + seeds
```

Or paste individual SQL files into the Supabase **SQL Editor** at [app.supabase.com](https://app.supabase.com).

> **Note:** Seed data files should use realistic but entirely fictional/anonymised data. Do not include any real patient information.
