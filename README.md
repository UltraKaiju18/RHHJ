# RHHJ — Rays of Hope Hospice Jinja

## Project Overview

**Rays of Hope Hospice Jinja (RHHJ)** is a home-based care program for cervical cancer patients in Uganda. This repository contains all design documentation, database schemas, mobile application source, and synchronisation configuration for the RHHJ digital health management solution.

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile UI | [FlutterFlow](https://flutterflow.io) | Cross-platform mobile interface with offline capability for handheld devices |
| Offline Sync | [PowerSync](https://www.powersync.com) | Bidirectional sync between the mobile app and the cloud database |
| Cloud Database | [Supabase](https://supabase.com) | Hosted PostgreSQL database with REST/GraphQL API and row-level security |

---

## Repository Structure

```
RHHJ/
├── docs/                        # Project documentation
│   ├── overview/                # Program overview & background documents
│   ├── process-diagrams/        # Workflow and process flow diagrams
│   └── data-structures/         # Current Excel data structures & data dictionaries
│
├── database/                    # Database design & management
│   ├── supabase/                # Supabase project config (storage, auth, edge functions)
│   ├── migrations/              # SQL migration scripts (versioned)
│   ├── schemas/                 # Entity-relationship diagrams & schema definitions
│   └── seed-data/               # Sample / reference data for testing
│
├── app/                         # Mobile application
│   ├── flutterflow/             # FlutterFlow exported project files
│   └── assets/                  # Images, icons, fonts, and other static assets
│
├── sync/                        # Offline synchronisation
│   └── config/                  # PowerSync sync rules and configuration files
│
└── scripts/                     # Utility & maintenance scripts
```

---

## Getting Started

1. **Review documentation** — Start with [`docs/overview/`](docs/overview/) for the program background and requirements.
2. **Understand the data** — See [`docs/data-structures/`](docs/data-structures/) for the existing Excel data collection forms.
3. **Database setup** — Follow [`database/README.md`](database/README.md) to provision the Supabase project and run migrations.
4. **Mobile app** — See [`app/README.md`](app/README.md) for FlutterFlow setup and export instructions.
5. **Offline sync** — See [`sync/README.md`](sync/README.md) for PowerSync configuration.

---

## Contributing

Please add project documents, process diagrams, and data structure files to the appropriate sub-folders described above. File-naming conventions and templates are provided within each sub-folder README.

---

## Contact

**Organisation:** Rays of Hope Hospice Jinja (RHHJ), Uganda  
**Repository Owner:** UltraKaiju18 (RayLRansom@gmail.com)
