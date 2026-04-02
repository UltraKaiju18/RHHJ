-- =============================================================================
-- RHHJ Initial Core Schema Migration
-- Rays of Hope Hospice Jinja – offline-first data capture
-- FlutterFlow + PowerSync + Supabase/Postgres
--
-- Apply this file once on a fresh Supabase Postgres instance:
--   Option A (Supabase CLI):  supabase db push
--   Option B (SQL Editor):    paste into Supabase > SQL Editor > Run
--
-- RLS policies are intentionally omitted; add in a later migration.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ---------------------------------------------------------------------------
-- team
-- A field team that holds a shared caseload of households / persons.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS team (
    team_id     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        text        NOT NULL,
    region      text        NOT NULL DEFAULT 'Busoga',
    active      boolean     NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------------
-- user_profile
-- One row per Supabase Auth user; keyed by auth.users.id (Option A).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profile (
    user_id     uuid        PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    full_name   text        NOT NULL,
    role        text        NOT NULL DEFAULT 'field_officer',
        -- e.g. 'admin', 'clinician', 'field_officer', 'me_officer'
    team_id     uuid        REFERENCES team (team_id) ON DELETE SET NULL,
    active      boolean     NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------------
-- location
-- Administrative hierarchy used for analytics and caseload scoping.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS location (
    location_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    district    text        NOT NULL,
    subcounty   text,
    parish      text,
    village     text,
    created_at  timestamptz NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------------
-- household
-- A household at a physical address; used for sync scoping and
-- household-level data capture.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS household (
    household_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    household_code  text,                           -- human-friendly label
    location_id     uuid        REFERENCES location (location_id) ON DELETE SET NULL,
    gps_lat         numeric(9,6),
    gps_lng         numeric(9,6),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);


-- ---------------------------------------------------------------------------
-- person
-- Person registry.  Created at first screening; idn is immutable.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS person (
    person_id       uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    idn             text        UNIQUE NOT NULL,    -- permanent programme ID
    first_name      text        NOT NULL,
    last_name       text        NOT NULL,
    sex             text,                           -- 'male','female','other'
    date_of_birth   date,
    approx_age_years integer,
    phone           text,
    location_id     uuid        REFERENCES location (location_id) ON DELETE SET NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_person_idn ON person (idn);


-- ---------------------------------------------------------------------------
-- household_member
-- Many-to-many: a person may belong to one household (or be tracked across
-- moves).  The current/active row can be determined by end_date IS NULL.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS household_member (
    household_id            uuid        NOT NULL REFERENCES household (household_id) ON DELETE RESTRICT,
    person_id               uuid        NOT NULL REFERENCES person    (person_id)    ON DELETE RESTRICT,
    relationship_to_head    text,
    start_date              date        NOT NULL DEFAULT CURRENT_DATE,
    end_date                date,
    created_at              timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (household_id, person_id)
);

CREATE INDEX IF NOT EXISTS idx_household_member_person ON household_member (person_id);


-- ---------------------------------------------------------------------------
-- team_household_assignment
-- Assigns a household (and all its members) to a team for caseload /
-- offline sync scoping.  start/end dates allow historical tracking.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS team_household_assignment (
    assignment_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id         uuid        NOT NULL REFERENCES team      (team_id)      ON DELETE RESTRICT,
    household_id    uuid        NOT NULL REFERENCES household (household_id) ON DELETE RESTRICT,
    start_date      date        NOT NULL DEFAULT CURRENT_DATE,
    end_date        date,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_team_household_assignment_team      ON team_household_assignment (team_id);
CREATE INDEX IF NOT EXISTS idx_team_household_assignment_household ON team_household_assignment (household_id);


-- ---------------------------------------------------------------------------
-- screening_event
-- One row per screening attempt; person gets idn at first screening.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS screening_event (
    screening_id        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid        NOT NULL REFERENCES person (person_id) ON DELETE RESTRICT,
    screening_date      date        NOT NULL,
    screening_round     integer,                    -- 1, 2, 3 ...
    screening_type      text        NOT NULL DEFAULT 'initial',
        -- 'initial', 'rescreen', 'followup'
    screening_outcome   text,
        -- 'eligible', 'not_eligible', 'pending'
    notes               text,
    captured_by         uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    captured_offline    boolean     NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_screening_event_person_date ON screening_event (person_id, screening_date);


-- ---------------------------------------------------------------------------
-- program_episode
-- Explicit enrolment episode; a person may have multiple over their
-- lifetime (e.g. enrolled → off-program → re-enrolled = new episode).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS program_episode (
    episode_id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid        NOT NULL REFERENCES person         (person_id)   ON DELETE RESTRICT,
    episode_start_date  date        NOT NULL,
    episode_end_date    date,
    start_reason        text,
        -- 'enrolled_from_screening', 'transferred_in', etc.
    end_reason          text,
        -- 'off_program', 'death', 'transfer_out', etc.
    start_screening_id  uuid        REFERENCES screening_event (screening_id) ON DELETE SET NULL,
    is_active           boolean     NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_program_episode_person ON program_episode (person_id, episode_start_date);


-- ---------------------------------------------------------------------------
-- patient_status_event
-- Status timeline (enrolled, remission, ltf, off_program, rip, etc.).
-- Querying "latest row by status_date per person" gives current status.
--
-- Constraint: RIP occurs at most once per person lifetime.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS patient_status_event (
    status_event_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id       uuid        NOT NULL REFERENCES person         (person_id)  ON DELETE RESTRICT,
    episode_id      uuid        REFERENCES program_episode (episode_id) ON DELETE RESTRICT,
    status_type     text        NOT NULL,
        -- 'enrolled', 'remission', 'ltf', 'off_program', 'rip',
        -- 'active_care', 'transferred_out'
    status_date     date        NOT NULL,
    reason_code     text,
    notes           text,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- One RIP per person lifetime (partial unique index).
CREATE UNIQUE INDEX IF NOT EXISTS uq_patient_status_rip_per_person
    ON patient_status_event (person_id)
    WHERE status_type = 'rip';

CREATE INDEX IF NOT EXISTS idx_patient_status_event_person_date
    ON patient_status_event (person_id, status_date);


-- ---------------------------------------------------------------------------
-- care_visit
-- One row per home (or facility/phone) visit; covers adult and child
-- patients with a discriminator field.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS care_visit (
    visit_id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid        NOT NULL REFERENCES person         (person_id)  ON DELETE RESTRICT,
    episode_id          uuid        REFERENCES program_episode (episode_id) ON DELETE RESTRICT,
    visit_date          date        NOT NULL,
    patient_type        text        NOT NULL DEFAULT 'adult',   -- 'adult','child'
    visit_type          text,       -- 'home','facility','phone'
    clinical_notes      text,
    pain_score          smallint,
    gps_lat             numeric(9,6),
    gps_lng             numeric(9,6),
    captured_by         uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    captured_offline    boolean     NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_care_visit_person_date ON care_visit (person_id, visit_date);


-- ---------------------------------------------------------------------------
-- consultation_event
-- Clinical consultations (can occur many times per person/episode).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS consultation_event (
    consultation_id     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid        NOT NULL REFERENCES person         (person_id)  ON DELETE RESTRICT,
    episode_id          uuid        REFERENCES program_episode (episode_id) ON DELETE RESTRICT,
    consultation_date   date        NOT NULL,
    consultation_type   text,
    details             text,
    captured_by         uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_consultation_event_person_date ON consultation_event (person_id, consultation_date);


-- ---------------------------------------------------------------------------
-- treatment_support_event
-- Each event where a person receives treatment support (transport, fees,
-- counselling, navigation, etc.).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS treatment_support_event (
    treatment_support_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id               uuid        NOT NULL REFERENCES person         (person_id)  ON DELETE RESTRICT,
    episode_id              uuid        REFERENCES program_episode (episode_id) ON DELETE RESTRICT,
    event_date              date        NOT NULL,
    facility_name           text,
    support_type            text,
        -- 'transport','fees','counseling','navigation', etc.
    amount                  numeric(12,2),
    currency                text        NOT NULL DEFAULT 'UGX',
    notes                   text,
    captured_by             uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    captured_offline        boolean     NOT NULL DEFAULT false,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_treatment_support_event_person_date
    ON treatment_support_event (person_id, event_date);


-- ---------------------------------------------------------------------------
-- household_assessment_event
-- Periodic household-level assessments (socioeconomic, caregiver, etc.).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS household_assessment_event (
    assessment_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id    uuid        NOT NULL REFERENCES household (household_id) ON DELETE RESTRICT,
    assessment_date date        NOT NULL,
    assessed_by     uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    caregiver_name  text,
    notes           text,
    captured_offline boolean   NOT NULL DEFAULT false,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_household_assessment_event_household_date
    ON household_assessment_event (household_id, assessment_date);


-- ---------------------------------------------------------------------------
-- household_support_event
-- Support events delivered at the household level (food, supplies, etc.).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS household_support_event (
    support_id      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id    uuid        NOT NULL REFERENCES household (household_id) ON DELETE RESTRICT,
    event_date      date        NOT NULL,
    support_type    text,
        -- 'food_package','supplies','caregiver_training', etc.
    details         text,
    amount          numeric(12,2),
    currency        text        NOT NULL DEFAULT 'UGX',
    provided_by     uuid        REFERENCES user_profile (user_id) ON DELETE SET NULL,
    captured_offline boolean   NOT NULL DEFAULT false,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_household_support_event_household_date
    ON household_support_event (household_id, event_date);
