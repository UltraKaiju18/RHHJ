# Mobile Application

This folder contains all mobile application files for the RHHJ patient management system.

## Sub-folders

| Folder | Purpose |
|--------|---------|
| [`flutterflow/`](flutterflow/) | FlutterFlow exported project files and custom code overrides |
| [`assets/`](assets/) | Images, icons, fonts, and other static assets used by the app |

## Technology: FlutterFlow

[FlutterFlow](https://flutterflow.io) is a low-code platform for building Flutter mobile apps. It compiles to native iOS and Android code and supports:

- **Offline-first capability** — local SQLite storage for data captured without network connectivity
- **Supabase integration** — built-in Supabase connector for authentication and database operations
- **PowerSync integration** — sync engine plugin for robust offline/online data synchronisation
- **Custom Dart code** — escape hatches for complex business logic

## Workflow

1. Build and update the app in the [FlutterFlow](https://app.flutterflow.io) web editor.
2. Export the Flutter project code to this repository under `flutterflow/`.
3. Any manual code overrides or custom widgets go into the exported project folder.
4. Build and test on Android and iOS devices.
