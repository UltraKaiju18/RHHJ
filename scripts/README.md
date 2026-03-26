# Scripts

This folder contains utility and maintenance scripts for the RHHJ project.

## Planned Scripts

| Script | Description |
|--------|-------------|
| `export-supabase-schema.sh` | Export the current Supabase schema to a local SQL file |
| `backup-database.sh` | Trigger a Supabase database backup |
| `generate-sample-data.py` | Generate anonymised sample data for testing |
| `validate-sync-rules.sh` | Validate PowerSync sync rules YAML against the schema |

## Usage

Each script will include inline documentation. Run from the repository root:

```bash
bash scripts/<script-name>.sh
```

> **Note:** Scripts may require environment variables set in a local `.env` file. See [`../database/supabase/README.md`](../database/supabase/README.md) for the required variables.
