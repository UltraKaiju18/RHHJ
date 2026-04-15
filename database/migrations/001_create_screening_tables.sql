-- =============================================================
-- Migration 001: Create Cervical Cancer Screening Tables
-- =============================================================
-- Derived from:
--   docs/data-structures/Screening Record 2024 final.xlsx
--   docs/data-structures/Screening 2025.xlsx
--
-- Each Excel workbook captures:
--   1. Individual patient screening records (one row per patient per session)
--   2. Per-session age-group summary (from the paired "Summary" sheet)
--   3. Monthly site-level aggregate rows (from the Annual / Monthly Summary sheet)
--
-- Tables created here:
--   screening_sessions           – one outreach / clinic event at a site on a date
--   screening_records            – one row per patient per session
--   screening_session_summaries  – age-group breakdown for a session
--   monthly_screening_summaries  – month × site aggregates (Annual Summary sheet)
-- =============================================================

-- ---------------------------------------------------------
-- Enable UUID generation (Supabase enables this by default;
-- included here for completeness / standalone execution)
-- ---------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================
-- ENUM TYPES
-- =============================================================

CREATE TYPE religion_type AS ENUM (
    'Catholic', 'Protestant', 'Muslim', 'Saved', 'Other'
);

CREATE TYPE marital_status_type AS ENUM (
    'Single', 'Married', 'Cohabiting', 'Divorced', 'Widowed'
);

CREATE TYPE family_structure_type AS ENUM (
    'Monogamous', 'Polygamous'
);

CREATE TYPE education_level_type AS ENUM (
    'None', 'Primary', 'Secondary', 'Tertiary'
);

CREATE TYPE hiv_status_type AS ENUM (
    'Negative', 'Positive', 'Unknown'
);

CREATE TYPE arv_status_type AS ENUM (
    'Not on ARV', '1st Line', '2nd Line'
);

CREATE TYPE sexual_partners_type AS ENUM (
    'None', '1-3', '4-6', '7-9', '10+'
);

-- Previous cervical screening method
CREATE TYPE prev_screening_method_type AS ENUM (
    'VIA', 'HPV', 'PAP', 'Histology', 'Other'
);

-- Previous cervical screening result
CREATE TYPE prev_screening_result_type AS ENUM (
    'Negative', 'Positive'
);

-- HPV DNA test result (positive flag only; no result = not done)
CREATE TYPE hpv_result_type AS ENUM (
    'Positive', 'Not Done'
);

-- Visual Inspection with Acetic acid (VIA) result
CREATE TYPE via_result_type AS ENUM (
    'Positive', 'Negative', 'Declined'
);

-- Speculum examination result
CREATE TYPE speculum_result_type AS ENUM (
    'Normal', 'Suspicious', 'Clinical Cancer', 'Other', 'Not Done'
);

-- Biopsy result
CREATE TYPE biopsy_result_type AS ENUM (
    'Positive', 'Negative', 'Referred for PAP Smear'
);

-- Breast examination classification
CREATE TYPE breast_exam_result_type AS ENUM (
    'Normal', 'Suspicious Lump', 'Clinical Cancer', 'Unknown'
);

-- Age group (used in summary sheets)
CREATE TYPE age_group_type AS ENUM (
    '<19', '20-30', '31-40', '41-50', '51-60', '>61'
);

-- =============================================================
-- TABLE: screening_sessions
-- One row per outreach or clinic screening event at a site.
-- Serves as the parent for all per-patient records and the
-- age-group summary for that event.
-- =============================================================

CREATE TABLE screening_sessions (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    session_date DATE        NOT NULL,
    site_name    TEXT        NOT NULL,   -- e.g. "Kangulamira HCIV", "RHHJ Clinic"
    notes        TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  screening_sessions              IS 'One outreach or clinic cervical-cancer screening event at a named site.';
COMMENT ON COLUMN screening_sessions.session_date IS 'Date of the screening session.';
COMMENT ON COLUMN screening_sessions.site_name    IS 'Name of the health centre, school, community site, or RHHJ clinic.';

-- =============================================================
-- TABLE: screening_records
-- Individual patient screening record.
-- One row per patient per session.
-- Derived from the per-site data sheets in the Excel workbooks.
-- =============================================================

CREATE TABLE screening_records (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL REFERENCES screening_sessions(id) ON DELETE CASCADE,

    -- ----------------------------------------------------------
    -- Patient identification
    -- ----------------------------------------------------------
    ipn          TEXT NOT NULL UNIQUE,  -- Internal Patient Number  e.g. S001/24, BS2501/25
    patient_name TEXT NOT NULL,
    age          SMALLINT,
    village      TEXT,
    phone        TEXT,
    tribe        TEXT,

    -- ----------------------------------------------------------
    -- Demographics
    -- ----------------------------------------------------------
    religion          religion_type,
    marital_status    marital_status_type,
    family_structure  family_structure_type,
    education_level   education_level_type,

    -- ----------------------------------------------------------
    -- Gynecological history
    -- ----------------------------------------------------------
    age_at_menarche        SMALLINT,   -- age at first menstrual period
    age_at_first_sex       SMALLINT,   -- age at first sexual contact
    age_at_first_delivery  SMALLINT,   -- age at first delivery
    num_pregnancies        SMALLINT,
    num_live_births        SMALLINT,
    children_alive         SMALLINT,

    -- ----------------------------------------------------------
    -- Gynecological symptoms  (checkbox flags)
    -- ----------------------------------------------------------
    gyn_symptom_none       BOOLEAN NOT NULL DEFAULT FALSE,
    gyn_symptom_bleeding   BOOLEAN NOT NULL DEFAULT FALSE,
    gyn_symptom_discharge  BOOLEAN NOT NULL DEFAULT FALSE,
    gyn_symptom_growth     BOOLEAN NOT NULL DEFAULT FALSE,
    gyn_symptom_urinary    BOOLEAN NOT NULL DEFAULT FALSE,
    gyn_symptom_pain       BOOLEAN NOT NULL DEFAULT FALSE,

    -- ----------------------------------------------------------
    -- Contraception
    -- ----------------------------------------------------------
    uses_contraception  BOOLEAN,

    -- ----------------------------------------------------------
    -- HIV status
    -- ----------------------------------------------------------
    hiv_status   hiv_status_type,
    arv_status   arv_status_type,       -- populated only when hiv_status = 'Positive'
    cd4_vl_result  TEXT,                -- free-text CD4 count or viral-load result
    cd4_vl_date    DATE,                -- date of CD4 / VL test
    cd4_vl_unknown BOOLEAN NOT NULL DEFAULT FALSE,  -- result not known

    -- ----------------------------------------------------------
    -- Risk factors
    -- ----------------------------------------------------------
    smoking              BOOLEAN,               -- recorded on 2024 form; nullable for 2025
    num_sexual_partners  sexual_partners_type,  -- '1-3', '4-6', etc.

    -- ----------------------------------------------------------
    -- Previous cervical screening
    -- ----------------------------------------------------------
    prev_screened          BOOLEAN,
    prev_screening_method  prev_screening_method_type,  -- VIA, HPV, PAP, Histology, Other
    prev_screening_result  prev_screening_result_type,  -- Negative / Positive

    -- ----------------------------------------------------------
    -- Current screening results
    -- ----------------------------------------------------------
    hpv_result           hpv_result_type,    -- HPV DNA test (added to 2025 form)
    via_result           via_result_type,    -- VIA result: Positive / Negative / Declined
    speculum_exam_result speculum_result_type,  -- Normal / Suspicious / Clinical Cancer / Other / Not Done

    -- ----------------------------------------------------------
    -- Biopsy
    -- ----------------------------------------------------------
    referred_for_biopsy       BOOLEAN NOT NULL DEFAULT FALSE,
    biopsy_referral_location  TEXT,               -- where referred for biopsy
    biopsy_result             biopsy_result_type, -- Positive / Negative / Referred for PAP

    -- ----------------------------------------------------------
    -- Treatment given  (checkbox flags)
    -- ----------------------------------------------------------
    treatment_cryotherapy      BOOLEAN NOT NULL DEFAULT FALSE,
    treatment_thermal_ablation BOOLEAN NOT NULL DEFAULT FALSE,
    treatment_antibiotics      BOOLEAN NOT NULL DEFAULT FALSE,
    treatment_referred_mulago  BOOLEAN NOT NULL DEFAULT FALSE,
    enrolled_on_programme      BOOLEAN NOT NULL DEFAULT FALSE,

    -- ----------------------------------------------------------
    -- Breast self-examination
    -- ----------------------------------------------------------
    breast_lump_found  BOOLEAN,       -- lump found on self-exam

    -- ----------------------------------------------------------
    -- Previous breast screening
    -- ----------------------------------------------------------
    prev_breast_screened       BOOLEAN,
    prev_breast_screening_when TEXT,   -- months or free-text date of previous screening
    prev_breast_result         TEXT,   -- Positive / Negative (free-text from Excel)

    -- ----------------------------------------------------------
    -- Breast examination result today
    -- ----------------------------------------------------------
    breast_result_today        TEXT,                  -- Positive / Negative (VIA-style)
    breast_biopsy_needed       BOOLEAN NOT NULL DEFAULT FALSE,
    breast_exam_classification breast_exam_result_type,  -- Normal / Suspicious Lump / Clinical Cancer

    -- ----------------------------------------------------------
    -- Enrollment and follow-up
    -- ----------------------------------------------------------
    appointment_date  DATE,
    follow_up         TEXT,

    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  screening_records             IS 'Individual patient cervical-cancer screening record. One row per patient per session.';
COMMENT ON COLUMN screening_records.ipn         IS 'Internal Patient Number assigned by RHHJ. Format: S###/YY (2024) or <SiteCode>####/YY (2025).';
COMMENT ON COLUMN screening_records.smoking     IS 'History of smoking. Captured explicitly on the 2024 form; field retained but nullable for 2025.';
COMMENT ON COLUMN screening_records.hpv_result  IS 'HPV DNA test result. Added to the 2025 form; NULL for 2024 records where test was not recorded.';

-- =============================================================
-- TABLE: screening_session_summaries
-- Age-group breakdown aggregate for a single screening session.
-- Derived from the paired "<Site> Summary" sheet in the workbooks.
-- One row per age-group per session.
-- =============================================================

CREATE TABLE screening_session_summaries (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID          NOT NULL REFERENCES screening_sessions(id) ON DELETE CASCADE,
    age_group   age_group_type NOT NULL,

    -- HIV / AIDS status counts
    hiv_negative  SMALLINT NOT NULL DEFAULT 0,
    hiv_positive  SMALLINT NOT NULL DEFAULT 0,
    hiv_unknown   SMALLINT NOT NULL DEFAULT 0,
    hiv_total     SMALLINT NOT NULL DEFAULT 0,

    -- VIA results
    via_positive  SMALLINT NOT NULL DEFAULT 0,
    via_negative  SMALLINT NOT NULL DEFAULT 0,
    via_declined  SMALLINT NOT NULL DEFAULT 0,

    -- HPV DNA test results
    hpv_positive  SMALLINT NOT NULL DEFAULT 0,
    hpv_total     SMALLINT NOT NULL DEFAULT 0,

    -- Speculum examination
    speculum_normal          SMALLINT NOT NULL DEFAULT 0,
    speculum_suspicious      SMALLINT NOT NULL DEFAULT 0,
    speculum_clinical_cancer SMALLINT NOT NULL DEFAULT 0,
    speculum_other           SMALLINT NOT NULL DEFAULT 0,
    speculum_not_done        SMALLINT NOT NULL DEFAULT 0,
    speculum_total           SMALLINT NOT NULL DEFAULT 0,

    -- Treatment given
    treatment_thermal    SMALLINT NOT NULL DEFAULT 0,
    treatment_declined   SMALLINT NOT NULL DEFAULT 0,
    treatment_antibiotic SMALLINT NOT NULL DEFAULT 0,
    treatment_total      SMALLINT NOT NULL DEFAULT 0,

    -- Referrals
    referral_leep      SMALLINT NOT NULL DEFAULT 0,
    referral_thermal   SMALLINT NOT NULL DEFAULT 0,
    referral_biopsy    SMALLINT NOT NULL DEFAULT 0,
    referral_pap_smear SMALLINT NOT NULL DEFAULT 0,
    referral_histology SMALLINT NOT NULL DEFAULT 0,
    referral_total     SMALLINT NOT NULL DEFAULT 0,

    -- Breast examination
    breast_normal          SMALLINT NOT NULL DEFAULT 0,
    breast_suspicious_lump SMALLINT NOT NULL DEFAULT 0,
    breast_clinical_cancer SMALLINT NOT NULL DEFAULT 0,
    breast_unknown         SMALLINT NOT NULL DEFAULT 0,
    breast_total           SMALLINT NOT NULL DEFAULT 0,
    breast_referral_biopsy    SMALLINT NOT NULL DEFAULT 0,
    breast_referral_mammogram SMALLINT NOT NULL DEFAULT 0,

    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_session_summaries_age_group UNIQUE (session_id, age_group)
);

COMMENT ON TABLE screening_session_summaries IS 'Age-group breakdown summary for a screening session (from the paired Summary sheet in the Excel workbook).';

-- =============================================================
-- TABLE: monthly_screening_summaries
-- Site-level aggregate per calendar month.
-- Derived from the "Annual Summary" (2024) and
-- "General Annual Summary 2025" / "RHHJ Monthly Summary" (2025)
-- sheets in the Excel workbooks.
-- One row per year × month × site.
-- =============================================================

CREATE TABLE monthly_screening_summaries (
    id         UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
    year       SMALLINT NOT NULL,
    month      SMALLINT NOT NULL CHECK (month BETWEEN 1 AND 12),
    site_name  TEXT     NOT NULL,

    -- HIV / AIDS status
    hiv_negative  SMALLINT NOT NULL DEFAULT 0,
    hiv_positive  SMALLINT NOT NULL DEFAULT 0,
    hiv_unknown   SMALLINT NOT NULL DEFAULT 0,
    hiv_total     SMALLINT NOT NULL DEFAULT 0,

    -- VIA results
    via_positive  SMALLINT NOT NULL DEFAULT 0,
    via_negative  SMALLINT NOT NULL DEFAULT 0,
    via_declined  SMALLINT NOT NULL DEFAULT 0,

    -- HPV DNA test results
    hpv_positive  SMALLINT NOT NULL DEFAULT 0,
    hpv_unknown   SMALLINT NOT NULL DEFAULT 0,
    hpv_total     SMALLINT NOT NULL DEFAULT 0,

    -- Speculum examination
    speculum_normal          SMALLINT NOT NULL DEFAULT 0,
    speculum_suspicious      SMALLINT NOT NULL DEFAULT 0,
    speculum_clinical_cancer SMALLINT NOT NULL DEFAULT 0,
    speculum_other           SMALLINT NOT NULL DEFAULT 0,
    speculum_not_done        SMALLINT NOT NULL DEFAULT 0,
    speculum_total           SMALLINT NOT NULL DEFAULT 0,

    -- Treatment given
    treatment_thermal    SMALLINT NOT NULL DEFAULT 0,
    treatment_declined   SMALLINT NOT NULL DEFAULT 0,
    treatment_antibiotic SMALLINT NOT NULL DEFAULT 0,
    treatment_total      SMALLINT NOT NULL DEFAULT 0,

    -- Referrals
    referral_leep      SMALLINT NOT NULL DEFAULT 0,
    referral_thermal   SMALLINT NOT NULL DEFAULT 0,
    referral_biopsy    SMALLINT NOT NULL DEFAULT 0,
    referral_pap_smear SMALLINT NOT NULL DEFAULT 0,
    referral_histology SMALLINT NOT NULL DEFAULT 0,
    referral_total     SMALLINT NOT NULL DEFAULT 0,

    -- Breast examination
    breast_normal             SMALLINT NOT NULL DEFAULT 0,
    breast_suspicious_lump    SMALLINT NOT NULL DEFAULT 0,
    breast_clinical_cancer    SMALLINT NOT NULL DEFAULT 0,
    breast_unknown            SMALLINT NOT NULL DEFAULT 0,
    breast_total              SMALLINT NOT NULL DEFAULT 0,
    breast_referral_biopsy    SMALLINT NOT NULL DEFAULT 0,
    breast_referral_mammogram SMALLINT NOT NULL DEFAULT 0,
    breast_referral_prolapse  SMALLINT NOT NULL DEFAULT 0,  -- added on 2025 form

    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_monthly_summary UNIQUE (year, month, site_name)
);

COMMENT ON TABLE  monthly_screening_summaries                   IS 'Site-level monthly aggregate screening data (from Annual / Monthly Summary sheets in the Excel workbooks).';
COMMENT ON COLUMN monthly_screening_summaries.breast_referral_prolapse IS 'Referrals for uterine/vaginal prolapse — column added on the 2025 Annual Summary sheet.';

-- =============================================================
-- INDEXES
-- =============================================================

-- screening_sessions
CREATE INDEX idx_screening_sessions_site       ON screening_sessions (site_name);
CREATE INDEX idx_screening_sessions_date       ON screening_sessions (session_date);
CREATE INDEX idx_screening_sessions_year_month ON screening_sessions (
    CAST(EXTRACT(YEAR  FROM session_date) AS SMALLINT),
    CAST(EXTRACT(MONTH FROM session_date) AS SMALLINT)
);

-- screening_records
CREATE INDEX idx_screening_records_session    ON screening_records (session_id);
CREATE INDEX idx_screening_records_hiv        ON screening_records (hiv_status);
CREATE INDEX idx_screening_records_via        ON screening_records (via_result);
CREATE INDEX idx_screening_records_speculum   ON screening_records (speculum_exam_result);
CREATE INDEX idx_screening_records_enrolled   ON screening_records (enrolled_on_programme);

-- screening_session_summaries
CREATE INDEX idx_session_summaries_session ON screening_session_summaries (session_id);

-- monthly_screening_summaries
CREATE INDEX idx_monthly_summaries_year_month ON monthly_screening_summaries (year, month);
CREATE INDEX idx_monthly_summaries_site       ON monthly_screening_summaries (site_name);

-- =============================================================
-- ROW-LEVEL SECURITY (Supabase)
-- Enable RLS and add policies after provisioning roles.
-- =============================================================

ALTER TABLE screening_sessions            ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_records             ENABLE ROW LEVEL SECURITY;
ALTER TABLE screening_session_summaries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_screening_summaries   ENABLE ROW LEVEL SECURITY;

-- =============================================================
-- END OF MIGRATION 001
-- =============================================================
