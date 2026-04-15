# Screening Data Dictionary

**Source files:**

| Excel File | Year | Sheets |
|-----------|------|--------|
| `Screening Record 2024 final.xlsx` | 2024 | Per-site data sheets + paired Summary sheets + Annual Summary + Quick Summary |
| `Screening 2025.xlsx` | 2025 | Per-site data sheets + paired Summary sheets + General Annual Summary 2025 + RHHJ Monthly Summary + Summary Template |

Each workbook captures two types of information:
1. **Individual patient records** — one row per patient per outreach/clinic session (per-site data sheets)
2. **Aggregate summaries** — age-group breakdown per session (paired Summary sheets) and monthly totals per site (Annual/Monthly Summary sheets)

The mappings below link Excel column labels to database columns.
Columns marked _(2024 only)_ or _(2025 only)_ differ between the two forms.

---

## 1. Individual Patient Record — Per-Site Data Sheet

### 1.1 Patient Identification

| Excel Column Label | DB Table | DB Column | Data Type | Required | Notes |
|--------------------|----------|-----------|-----------|----------|-------|
| `#IPN` | `screening_records` | `ipn` | TEXT | Yes | Internal Patient Number. `S###/YY` in 2024; `<SiteCode>####/YY` in 2025. Unique across all records. |
| `Name` | `screening_records` | `patient_name` | TEXT | Yes | Full patient name |
| `Age` | `screening_records` | `age` | SMALLINT | No | Age in years at time of screening |
| `Village` | `screening_records` | `village` | TEXT | No | Patient's home village |
| `Phone` | `screening_records` | `phone` | TEXT | No | Contact phone number |
| `Tribe` | `screening_records` | `tribe` | TEXT | No | Ethnic group |
| Sheet header Date | `screening_sessions` | `session_date` | DATE | Yes | Date from the sheet title row (e.g. "Date: 30/1/2024") |
| Sheet header Place | `screening_sessions` | `site_name` | TEXT | Yes | Site name from the sheet title row (e.g. "Place: Kangulamira HCIV") |

### 1.2 Religion  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Cath` | `religion` | `'Catholic'` |
| `Prot.` | `religion` | `'Protestant'` |
| `Musl.` | `religion` | `'Muslim'` |
| `Saved` | `religion` | `'Saved'` |
| `Other` (Religion) | `religion` | `'Other'` |

### 1.3 Marital Status  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Sing` | `marital_status` | `'Single'` |
| `Mar` | `marital_status` | `'Married'` |
| `CoH` | `marital_status` | `'Cohabiting'` |
| `Div` | `marital_status` | `'Divorced'` |
| `Wid` | `marital_status` | `'Widowed'` |

### 1.4 Family Structure  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Mono` | `family_structure` | `'Monogamous'` |
| `Poly` | `family_structure` | `'Polygamous'` |

### 1.5 Education  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `None` (Education) | `education_level` | `'None'` |
| `Prim` | `education_level` | `'Primary'` |
| `Sec` | `education_level` | `'Secondary'` |
| `Tert` | `education_level` | `'Tertiary'` |

### 1.6 Gynecological History

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `1st period` | `age_at_menarche` | SMALLINT | Age at first menstrual period |
| `1st sex.contact` | `age_at_first_sex` | SMALLINT | Age at first sexual contact |
| `1st delivery` | `age_at_first_delivery` | SMALLINT | Age at first delivery |
| `# Preg.` | `num_pregnancies` | SMALLINT | Total number of pregnancies |
| `# live births` | `num_live_births` | SMALLINT | Number of live births |
| `Children alive` | `children_alive` | SMALLINT | Number of living children |

### 1.7 Gynecological Symptoms  _(checkboxes — mark all that apply)_

| Excel Column Label | DB Column | Notes |
|--------------------|-----------|-------|
| `No` (Gyn.Symptoms) | `gyn_symptom_none` | No symptoms — mutually exclusive with the others |
| `Bleed.` | `gyn_symptom_bleeding` | Abnormal bleeding |
| `Disch.` | `gyn_symptom_discharge` | Abnormal discharge |
| `Growth` | `gyn_symptom_growth` | Visible growth |
| `Urinary` | `gyn_symptom_urinary` | Urinary symptoms |
| `Pain` | `gyn_symptom_pain` | Pelvic or abdominal pain |

### 1.8 Contraception  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `N` (Contraception) | `uses_contraception` | `FALSE` |
| `Y` (Contraception) | `uses_contraception` | `TRUE` |

### 1.9 HIV Status  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `HIV-` | `hiv_status` | `'Negative'` |
| `HIV+` | `hiv_status` | `'Positive'` |
| `UNKNOWN` | `hiv_status` | `'Unknown'` |

### 1.10 HIV Positive — ARV Status  _(checkbox — mark one; only if HIV+)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Not on ARV` / `No ARV` | `arv_status` | `'Not on ARV'` |
| `1st line` | `arv_status` | `'1st Line'` |
| `2nd Line` | `arv_status` | `'2nd Line'` |

### 1.11 CD4 / Viral Load

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `Result of CD4/Vl` | `cd4_vl_result` | TEXT | Free-text CD4 count or viral-load value |
| `month since test` _(2024)_ / `Date tested` _(2025)_ | `cd4_vl_date` | DATE | 2024 form stores months-since-test; migrate as approximate date |
| `Doesn't know` _(2024)_ / `Unknown` _(2025)_ | `cd4_vl_unknown` | BOOLEAN | Set TRUE when result is not known |

### 1.12 History of Smoking  _(2024 form only)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `No` (History of smoking) | `smoking` | `FALSE` |
| `Yes` (History of smoking) | `smoking` | `TRUE` |

> **Note:** The smoking field was removed from the 2025 form. The DB column is nullable; set `NULL` when importing 2025 records.

### 1.13 Number of Sexual Partners  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `None` (Sexual partners) | `num_sexual_partners` | `'None'` |
| `1-3 partners` / `1-3 part` | `num_sexual_partners` | `'1-3'` |
| `4-6 part` | `num_sexual_partners` | `'4-6'` |
| `7-9 part` | `num_sexual_partners` | `'7-9'` |
| `10+` | `num_sexual_partners` | `'10+'` |

### 1.14 Previous Cervical Screening  _(checkbox — mark one or more)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `No` (Prev Cervical Screening) | `prev_screened` | `FALSE` |
| `VIA` | `prev_screened` = TRUE; `prev_screening_method` | `'VIA'` |
| `HPV` _(2025 only)_ | `prev_screened` = TRUE; `prev_screening_method` | `'HPV'` |
| `PAP` | `prev_screened` = TRUE; `prev_screening_method` | `'PAP'` |
| `Histology` | `prev_screened` = TRUE; `prev_screening_method` | `'Histology'` |
| `Other` (Prev Screening) | `prev_screened` = TRUE; `prev_screening_method` | `'Other'` |

### 1.15 Result of Previous Screening  _(checkbox — mark one)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Neg` (prev screening) | `prev_screening_result` | `'Negative'` |
| `pos` (prev screening) | `prev_screening_result` | `'Positive'` |

### 1.16 Current Screening Results

#### HPV DNA Test  _(2025 form only; row 2 sub-header "HPV")_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Pos` (HPV) | `hpv_result` | `'Positive'` |
| _(not marked)_ | `hpv_result` | `'Not Done'` or NULL |

#### VIA Result  _(row 2 sub-header "VIA" in 2025; implied in "Result today" in 2024)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Pos` (VIA) | `via_result` | `'Positive'` |
| `Neg` (VIA) | `via_result` | `'Negative'` |
| `Declined` _(summary sheets only)_ | `via_result` | `'Declined'` |

#### Speculum Examination  _(row 2 sub-header "Speculum Exam" in 2025)_

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Normal` (Speculum) | `speculum_exam_result` | `'Normal'` |
| `suspicious` | `speculum_exam_result` | `'Suspicious'` |
| `Clincal Cancer` _(misspelling in source form)_ | `speculum_exam_result` | `'Clinical Cancer'` |
| `Others` | `speculum_exam_result` | `'Other'` |
| _(not marked)_ | `speculum_exam_result` | `'Not Done'` or NULL |

### 1.17 Biopsy Referral

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `Yes` (referred for biopsy) | `referred_for_biopsy` | BOOLEAN | |
| `Where` | `biopsy_referral_location` | TEXT | Free-text facility name |
| `No` (referred for biopsy) | `referred_for_biopsy` | BOOLEAN | FALSE |

### 1.18 Result of Biopsy

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Pos` (biopsy) | `biopsy_result` | `'Positive'` |
| `neg` (biopsy) | `biopsy_result` | `'Negative'` |
| `referred for PAP Smear` | `biopsy_result` | `'Referred for PAP Smear'` |

### 1.19 Treatment and Follow-up Given  _(checkboxes — mark all that apply)_

| Excel Column Label | DB Column | Notes |
|--------------------|-----------|-------|
| `Cryo` | `treatment_cryotherapy` | Cryotherapy |
| `Thermal` | `treatment_thermal_ablation` | Thermal ablation |
| `Anti biotics` / `Antibiotics` | `treatment_antibiotics` | Antibiotic treatment |
| `Refer to Mulago` | `treatment_referred_mulago` | Referral to Mulago National Referral Hospital |
| `Enrlled on programme` _(misspelling in source form)_ | `enrolled_on_programme` | Enrolled on the RHHJ care programme |

### 1.20 Breast Self-Examination

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `No` (Lump at Breast Self exam) | `breast_lump_found` | BOOLEAN | FALSE |
| `Yes` (Lump at Breast Self exam) | `breast_lump_found` | BOOLEAN | TRUE |
| `When` | `prev_breast_screening_when` | TEXT | See 1.21 |

### 1.21 Previous Breast Screening

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `No` (previous Breast screening) | `prev_breast_screened` | BOOLEAN | FALSE |
| `Yes` (previous Breast screening) | `prev_breast_screened` | BOOLEAN | TRUE |
| `When (monhs)` / `When (months)` | `prev_breast_screening_when` | TEXT | Duration in months or free-text date |

### 1.22 Result of Previous Breast Exam

| Excel Column Label | DB Column | Notes |
|--------------------|-----------|-------|
| `Pos` (prev breast) | `prev_breast_result` | Free-text "Positive" |
| `neg` (prev breast) | `prev_breast_result` | Free-text "Negative" |
| `Result` _(2025 label)_ | `prev_breast_result` | Free-text |

### 1.23 Breast Examination Result Today

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `Normal` (Breast today) | `breast_exam_classification` | ENUM | `'Normal'` |
| `Suspicious lump` | `breast_exam_classification` | ENUM | `'Suspicious Lump'` |
| `Clinical Cancer` (Breast) | `breast_exam_classification` | ENUM | `'Clinical Cancer'` |
| `Unknown` _(2025 only)_ | `breast_exam_classification` | ENUM | `'Unknown'` |
| `Pos` (breast today) | `breast_result_today` | TEXT | Free-text VIA-style |
| `neg` (breast today) | `breast_result_today` | TEXT | Free-text |

### 1.24 Breast Biopsy

| Excel Column Label | DB Column | Stored Value |
|--------------------|-----------|-|
| `Yes` (Needs biopsy) | `breast_biopsy_needed` | TRUE |
| `No` (Needs biopsy) | `breast_biopsy_needed` | FALSE |

### 1.25 Enrollment and Appointment

| Excel Column Label | DB Column | Data Type | Notes |
|--------------------|-----------|-----------|-------|
| `yes` (Enroll on programme) | `enrolled_on_programme` | BOOLEAN | TRUE |
| `No` (Enroll on programme) | `enrolled_on_programme` | BOOLEAN | FALSE |
| `Appointment for enrollment` | `appointment_date` | DATE | |
| `Enrolled` _(2024 only)_ | `enrolled_on_programme` | BOOLEAN | |
| `Follow-up` _(2024 only)_ | `follow_up` | TEXT | Free-text |
| `Referral to` _(2025 only)_ | `follow_up` | TEXT | Referral destination |

---

## 2. Per-Session Age-Group Summary Sheet

**Mapped to:** `screening_session_summaries`

Each Summary sheet (e.g. "Kangulamira Summary", "Buyende Jan Summary") has
one row per age group.  The session is identified by the matching data sheet.

### Age Groups

| Excel Row Label | DB Column `age_group` Value |
|-----------------|--------------------------|
| `<19` | `'<19'` |
| `20 – 30` | `'20-30'` |
| `31– 40` | `'31-40'` |
| `41– 50` | `'41-50'` |
| `51– 60` | `'51-60'` |
| `>61` | `'>61'` |
| `Totals` | _(not stored — derived by summing age-group rows)_ |

### Summary Column Mapping

| Excel Column Label | DB Column | Notes |
|--------------------|-----------|-------|
| HIV / AIDS STATUS: `NEG` | `hiv_negative` | |
| HIV / AIDS STATUS: `POS` | `hiv_positive` | |
| HIV / AIDS STATUS: `Unknown` | `hiv_unknown` | |
| HIV / AIDS STATUS: `TOTAL` | `hiv_total` | |
| VIA RESULTS: `VIA POS` / `POS` | `via_positive` | |
| VIA RESULTS: `NEG` | `via_negative` | |
| VIA RESULTS: `Declined` | `via_declined` | |
| HPV: `HPV Pos` / `Pos` | `hpv_positive` | |
| HPV: `TOTAL` | `hpv_total` | |
| Speculum Exam: `Normal` | `speculum_normal` | |
| Speculum Exam: `suspicious` | `speculum_suspicious` | |
| Speculum Exam: `Clinical Cancer` | `speculum_clinical_cancer` | |
| Speculum Exam: `Other` | `speculum_other` | |
| Speculum Exam: `Not done` / `Not Done` | `speculum_not_done` | |
| Speculum Exam: `TOTAL` | `speculum_total` | |
| TREATMENT GIVEN: `Thermal` | `treatment_thermal` | |
| TREATMENT GIVEN: `Declined` | `treatment_declined` | |
| TREATMENT GIVEN: `Antibiotic` | `treatment_antibiotic` | |
| TREATMENT GIVEN: `TOTAL` | `treatment_total` | |
| REFERRALS: `LEEP` | `referral_leep` | |
| REFERRALS: `Thermal` | `referral_thermal` | |
| REFERRALS: `Biopys` / `Biopsy` | `referral_biopsy` | `Biopys` is the misspelling used in the Excel form; normalize to `'Biopsy'` on import |
| REFERRALS: `PAPsmear` / `PAPsmear` | `referral_pap_smear` | |
| REFERRALS: `HISTOLOGY` / `Histology` | `referral_histology` | |
| BREAST EXAM: `Normal` | `breast_normal` | |
| BREAST EXAM: `Suspicious lump` | `breast_suspicious_lump` | |
| BREAST EXAM: `Clinical Cancer` | `breast_clinical_cancer` | |
| BREAST EXAM: `Unknown` | `breast_unknown` | |
| BREAST EXAM: `Total` | `breast_total` | |
| REFERRALS: `Biopys` (Breast) | `breast_referral_biopsy` | See note above on `Biopys` misspelling |
| REFERRALS: `MAMOGRAM` | `breast_referral_mammogram` | `MAMOGRAM` is the misspelling used in the Excel form; normalize to `'Mammogram'` on import |

---

## 3. Annual / Monthly Summary Sheets

**Mapped to:** `monthly_screening_summaries`

### Source Sheets

| Workbook | Sheet Name | Content |
|---------|-----------|---------|
| 2024 | `Annual Summary` | Month × site totals for full year 2024 |
| 2024 | `Quick Summary` | Monthly totals (condensed) for 2024 |
| 2025 | `General Annual Summary 2025` | Month × site totals for 2025 |
| 2025 | `RHHJ Monthly Summary` | RHHJ-clinic rows only |
| 2025 | `Summary Template` | Blank template (not data — do not import) |

### Column Mapping

The `monthly_screening_summaries` table uses the same column names and
categories as `screening_session_summaries` (see section 2 above), plus:

| Excel Column Label | DB Column | Notes |
|--------------------|-----------|-------|
| `PERIOD: MONTH` | `month` | Integer 1–12 derived from month name |
| `PERIOD: SITE` | `site_name` | |
| _(workbook year)_ | `year` | 2024 or 2025 |
| REFERRALS: `Prolapse` _(2025 only)_ | `breast_referral_prolapse` | Uterine/vaginal prolapse referral — added in 2025 |

---

## 4. Allowed Value Reference

### Enumerations

| Enum Name | Values |
|-----------|--------|
| `religion_type` | Catholic, Protestant, Muslim, Saved, Other |
| `marital_status_type` | Single, Married, Cohabiting, Divorced, Widowed |
| `family_structure_type` | Monogamous, Polygamous |
| `education_level_type` | None, Primary, Secondary, Tertiary |
| `hiv_status_type` | Negative, Positive, Unknown |
| `arv_status_type` | Not on ARV, 1st Line, 2nd Line |
| `sexual_partners_type` | None, 1-3, 4-6, 7-9, 10+ |
| `prev_screening_method_type` | VIA, HPV, PAP, Histology, Other |
| `prev_screening_result_type` | Negative, Positive |
| `hpv_result_type` | Positive, Not Done |
| `via_result_type` | Positive, Negative, Declined |
| `speculum_result_type` | Normal, Suspicious, Clinical Cancer, Other, Not Done |
| `biopsy_result_type` | Positive, Negative, Referred for PAP Smear |
| `breast_exam_result_type` | Normal, Suspicious Lump, Clinical Cancer, Unknown |
| `age_group_type` | <19, 20-30, 31-40, 41-50, 51-60, >61 |

---

## 5. Form Differences: 2024 vs. 2025

| Feature | 2024 Form | 2025 Form | DB Handling |
|---------|-----------|-----------|-------------|
| History of smoking | ✅ Columns 46–47 (`No`/`Yes`) | ❌ Removed | `smoking` column is nullable |
| HPV in previous screening methods | ❌ Not listed | ✅ Added | `'HPV'` value added to `prev_screening_method_type` enum |
| HPV current test result | ❌ Not on form | ✅ Row 2 sub-header "HPV"; Col = `Pos` | `hpv_result` column is nullable |
| VIA & Speculum separated | ❌ Combined under "Result today" | ✅ Separate sub-headers: "HPV", "VIA", "Speculum Exam" | Single `via_result` and `speculum_exam_result` columns used for both years |
| Patient ID format | `S###/YY` (sequential) | `<SiteCode>####/YY` | Single `ipn` TEXT column |
| CD4/VL date field label | `month since test` | `Date tested` | `cd4_vl_date` DATE column |
| Prolapse referral in Annual Summary | ❌ Not present | ✅ Added | `breast_referral_prolapse` in `monthly_screening_summaries` |
| `Family Structure` group header | ✅ Present (cols 17–18) | ❌ Merged into Marital Status header | `family_structure` column covers both years |
| `Unknown` breast exam result | ❌ Not on form | ✅ Added | `'Unknown'` value added to `breast_exam_result_type` enum |
