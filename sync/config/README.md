# PowerSync Configuration

This folder holds PowerSync service configuration files, primarily the **sync rules** YAML file.

## Files

| File | Description |
|------|-------------|
| `sync-rules.yaml` | Defines which Supabase tables and rows are synced to each user's device |

## sync-rules.yaml (starter template)

The file below is a starting-point template. Update it once the database schema has been finalised.

```yaml
# PowerSync Sync Rules for RHHJ
# Docs: https://docs.powersync.com/usage/sync-rules

bucket_definitions:
  # Sync all patients assigned to the authenticated care worker
  care_worker_patients:
    parameters: SELECT id FROM care_workers WHERE user_id = token_parameters.user_id
    data:
      - SELECT * FROM patients WHERE care_worker_id = bucket.id
      - SELECT * FROM visits WHERE patient_id IN (
            SELECT id FROM patients WHERE care_worker_id = bucket.id
          )
      - SELECT * FROM assessments WHERE visit_id IN (
            SELECT v.id FROM visits v
            JOIN patients p ON v.patient_id = p.id
            WHERE p.care_worker_id = bucket.id
          )

  # Reference / lookup data synced to all users
  reference_data:
    data:
      - SELECT * FROM locations
      - SELECT * FROM medications
```

## Applying Changes

After editing `sync-rules.yaml`:

1. Log in to [app.powersync.com](https://app.powersync.com).
2. Navigate to your RHHJ instance.
3. Upload or paste the updated sync rules.
4. Deploy the changes.
