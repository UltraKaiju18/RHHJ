# Supabase Configuration

This folder holds Supabase-specific configuration files for the RHHJ project.

## Contents

| File / Folder | Description |
|---------------|-------------|
| `config.toml` | Supabase CLI project configuration (add when using Supabase CLI) |
| `functions/` | Edge Functions (serverless functions running on Deno) |
| `policies/` | Row Level Security (RLS) policy SQL scripts |
| `storage/` | Storage bucket configuration |

## Supabase CLI

The [Supabase CLI](https://supabase.com/docs/guides/cli) can be used to manage your project locally:

```bash
# Install Supabase CLI
npm install -g supabase

# Initialise a local Supabase project (run from repository root)
supabase init

# Link to your hosted Supabase project
supabase link --project-ref <your-project-ref>

# Run migrations against the remote database
supabase db push
```

## Environment Variables

Create a `.env` file at the repository root (it is excluded from Git via `.gitignore`):

```
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
```

**Never commit API keys or secrets to this repository.**
