# Data Structures

Place existing Excel data collection forms, CSV exports, and data dictionaries in this folder.

## Purpose

These files will be used to:
1. Understand the current data being collected in the RHHJ program.
2. Design the SQL database schema in [`../../database/schemas/`](../../database/schemas/).
3. Map existing fields to the new Supabase database tables.

## Suggested Files

| File Name | Description |
|-----------|-------------|
| `patient-data-form.xlsx` | Current Excel form used for patient registration and demographics |
| `visit-data-form.xlsx` | Current Excel form used during home visits |
| `data-dictionary.md` | Definitions for all data fields, including allowed values and data types |

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
