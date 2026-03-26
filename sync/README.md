# Offline Synchronisation

This folder contains configuration for **PowerSync** — the offline sync engine that keeps the FlutterFlow mobile app in sync with the Supabase cloud database.

## Sub-folders

| Folder | Purpose |
|--------|---------|
| [`config/`](config/) | PowerSync sync rules and service configuration files |

## Technology: PowerSync

[PowerSync](https://www.powersync.com) is a service that:
- Maintains a local SQLite database on the mobile device.
- Syncs data bidirectionally with Supabase (or any PostgreSQL-compatible backend).
- Handles conflict resolution and queued writes when the device is offline.

## How It Works

```
Mobile Device (FlutterFlow + PowerSync SDK)
        ↕  (when online)
PowerSync Service  ←→  Supabase PostgreSQL
```

1. The care worker captures data offline → stored in local SQLite.
2. When connectivity resumes, PowerSync syncs local changes to Supabase.
3. Central database updates (e.g., from other users) are pulled to the device.

## Setup Overview

1. Create a PowerSync account at [app.powersync.com](https://app.powersync.com).
2. Connect PowerSync to your Supabase project.
3. Define **sync rules** in [`config/sync-rules.yaml`](config/sync-rules.yaml) to control which data each user syncs.
4. Add the PowerSync Flutter SDK to the FlutterFlow project (see [`../app/flutterflow/`](../app/flutterflow/)).

## Further Reading

- [PowerSync Docs](https://docs.powersync.com)
- [PowerSync + Supabase Integration Guide](https://docs.powersync.com/integration-guides/supabase)
- [PowerSync + FlutterFlow Guide](https://docs.powersync.com/client-sdk-references/flutter)
