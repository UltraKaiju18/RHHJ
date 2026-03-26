# FlutterFlow Project

This folder will contain the Flutter/FlutterFlow exported project source code once the app has been built.

## Setup

1. Open the project in [FlutterFlow](https://app.flutterflow.io).
2. Connect the **Supabase** backend:
   - Go to **Settings → Supabase** and enter your project URL and anon key.
3. Add the **PowerSync** integration for offline sync (see [`../../sync/`](../../sync/)).
4. Export the project via **Code → Download Code** and place the exported folder here.

## Folder Structure (after export)

```
flutterflow/
├── lib/
│   ├── app_state.dart
│   ├── main.dart
│   ├── pages/           # App screens
│   ├── components/      # Reusable widgets
│   ├── backend/
│   │   ├── supabase/    # Supabase client and queries
│   │   └── schema.dart  # PowerSync schema definition
│   └── custom_code/     # Custom Dart actions and widgets
├── assets/
├── pubspec.yaml
└── README.md
```

## Key Screens (planned)

| Screen | Description |
|--------|-------------|
| Login | Care worker authentication via Supabase Auth |
| Patient List | Browse and search registered patients (offline capable) |
| Patient Registration | Register a new patient |
| Visit Record | Capture a home visit assessment |
| Sync Status | Show offline queue and last sync time |
