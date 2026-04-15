# Data Structures

Place existing Excel data collection forms, CSV exports, and data dictionaries in this folder.

## Purpose

These files will be used to:
1. Understand the current data being collected in the RHHJ program.
2. Design the SQL database schema in [`../../database/schemas/`](../../database/schemas/).
3. Map existing fields to the new Supabase database tables.

## Current Data Files

### Screening

| File | Description |
|------|-------------|
| `Screening Record 2024 final.xlsx` | Full 2024 cervical-cancer screening records — per-site data sheets + Summary sheets + Annual Summary |
| `Screening 2025.xlsx` | Full 2025 cervical-cancer screening records — per-site data sheets + Summary sheets + General Annual Summary |
| [`screening-data-dictionary.md`](screening-data-dictionary.md) | Data dictionary mapping every Excel column to its database field, covering both 2024 and 2025 forms |

### Treatment

| File | Description |
|------|-------------|
| `2501 JanuaryTreatment Data Record 2025.xlsx` – `2511 November Treatment Data Record 2025.xlsx` | Monthly treatment records for 2025 (data structure TBD) |
| `January Patients Data 2025.xlsx` – `November Patients Data 2025.xlsx` | Monthly patient data files for 2025 (data structure TBD) |

### Other Reference Documents

| File | Description |
|------|-------------|
| `HPV Vaccination Record July 2024.xlsx` | HPV vaccination records (data structure TBD) |
| `Target tracking Tool 2025 final.xlsx` | Programme target-tracking tool for 2025 |
| `Copy of Screening + consent.pdf` | Screening consent form |
| `Copy of screening card.pdf` | Patient screening card |
| `Copy of PATIENT CARE SHEET.pdf` | Patient care sheet |
| `Copy of PATIENTS CARD.pdf` | Patient card |
| `Copy of RHHJ CONSULTATION FORM, Feb.2025.pdf` | Consultation form (2025 version) |
| `Copy of REFERRAL LETTER.pdf` | Referral letter template |
| `Copy of Daily Community Activity Report.pdf` | Community activity report form |

## Data Dictionary Template

When adding Excel forms, please also create a corresponding Markdown data dictionary entry:

```markdown
## Table: patients

| Field Name       | Excel Column | Data Type | Required | Allowed Values / Notes        |
|------------------|-------------|-----------|----------|-------------------------------|
| patient_id       | A           | UUID      | Yes      | Auto-generated                |
| first_name       | B           | Text      | Yes      |                               |
| last_name        | C           | Text      | Yes      |                               |
| date_of_birth    | D           | Date      | Yes      | YYYY-MM-DD                    |
| village          | E           | Text      | No       |                               |
| diagnosis_stage  | F           | Text      | Yes      | Stage I, II, III, IV          |
```

