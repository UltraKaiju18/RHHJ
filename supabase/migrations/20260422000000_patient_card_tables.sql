-- =============================================================================
-- Migration: Patient Card Tables (offline-first, version-based conflict rejection)
-- Rays of Hope Hospice Jinja – FlutterFlow + PowerSync + Supabase/Postgres
--
-- Tables:
--   public.patient_cards                      – one row per patient card
--   public.patient_card_clinical_appointments – append-only appointment rows
--
-- Concurrency strategy:
--   patient_cards uses an integer `version` column.
--   Updates must be performed via the update_patient_card_if_version() RPC,
--   which rejects writes whose expected_version no longer matches the server,
--   surfacing an explicit conflict error to the offline sync queue.
--
-- Date handling:
--   Dates are stored as the `date` type (ISO-8601 internally).
--   The UI accepts and displays dates as DD/MM/YYYY; the app layer is
--   responsible for parsing to ISO before inserting.
--
-- Apply via Supabase CLI:  supabase db push
-- Or paste into:           Supabase > SQL Editor > Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ---------------------------------------------------------------------------
-- public.patient_cards
-- One row per physical patient card issued by RHHJ.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.patient_cards (
    id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id  uuid        NULL,                -- future FK to public.patients
    ipno        text        NOT NULL,            -- Internal Patient Number; required
    full_name   text        NOT NULL,
    district    text        NULL,
    village     text        NULL,
    route       text        NULL,
    version     int         NOT NULL DEFAULT 1,  -- optimistic-concurrency version
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT patient_cards_ipno_unique UNIQUE (ipno)
);

COMMENT ON TABLE  public.patient_cards            IS 'Physical patient card issued by RHHJ. One row per card.';
COMMENT ON COLUMN public.patient_cards.ipno       IS 'Internal Patient Number (IPNO). Required and unique across all cards.';
COMMENT ON COLUMN public.patient_cards.version    IS 'Optimistic-concurrency version counter. Incremented on every accepted update. Offline clients must supply the version they last read; mismatches are rejected.';
COMMENT ON COLUMN public.patient_cards.patient_id IS 'Optional future foreign key to public.patients once that table is created.';


-- ---------------------------------------------------------------------------
-- public.patient_card_clinical_appointments
-- Append-only child rows recording clinical appointment entries.
-- No version column — rows are never edited after insert.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.patient_card_clinical_appointments (
    id               uuid  PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_card_id  uuid  NOT NULL
        REFERENCES public.patient_cards (id) ON DELETE CASCADE,

    -- stored as a real date; UI layer handles DD/MM/YYYY ↔ ISO conversion
    appointment_date date  NULL,
    appointment_day  text  NULL,   -- written label e.g. "Monday" or left blank
    location         text  NULL,

    sort_order       int   NOT NULL DEFAULT 0,

    created_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.patient_card_clinical_appointments                 IS 'Clinical appointment rows belonging to a patient card. Append-only; rows are not updated after creation.';
COMMENT ON COLUMN public.patient_card_clinical_appointments.appointment_date IS 'Date stored as ISO date. The UI accepts/displays DD/MM/YYYY; parse to ISO before inserting.';
COMMENT ON COLUMN public.patient_card_clinical_appointments.appointment_day  IS 'Day label as written on the paper card (e.g. "Monday"). Free text.';


-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_patient_cards_ipno
    ON public.patient_cards (ipno);

CREATE INDEX IF NOT EXISTS idx_patient_card_appts_card_id
    ON public.patient_card_clinical_appointments (patient_card_id);

CREATE INDEX IF NOT EXISTS idx_patient_card_appts_date
    ON public.patient_card_clinical_appointments (appointment_date);


-- ---------------------------------------------------------------------------
-- Trigger: automatically maintain updated_at on patient_cards
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.set_updated_at() IS 'Generic before-update trigger that stamps updated_at = now().';

CREATE OR REPLACE TRIGGER trg_patient_cards_set_updated_at
    BEFORE UPDATE ON public.patient_cards
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();


-- ---------------------------------------------------------------------------
-- RPC: version-checked update for patient_cards
--
-- The offline sync queue calls this function when pushing a locally-edited
-- patient card back to the server.  It supplies the version it last saw
-- (p_expected_version).  If another device has already committed a newer
-- version, the function raises an exception with errcode P0002 so the
-- caller can mark the queue item as "conflict" and prompt manual review.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_patient_card_if_version(
    p_id               uuid,
    p_expected_version int,
    p_ipno             text,
    p_full_name        text,
    p_district         text,
    p_village          text,
    p_route            text
)
RETURNS public.patient_cards
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_row public.patient_cards;
BEGIN
    UPDATE public.patient_cards
    SET
        ipno      = p_ipno,
        full_name = p_full_name,
        district  = p_district,
        village   = p_village,
        route     = p_route,
        version   = version + 1
    WHERE id      = p_id
      AND version = p_expected_version
    RETURNING * INTO v_row;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'conflict: patient_cards row % has been modified by another client (expected version %)',
            p_id, p_expected_version
            USING ERRCODE = 'P0002';
    END IF;

    RETURN v_row;
END;
$$;

COMMENT ON FUNCTION public.update_patient_card_if_version(uuid, int, text, text, text, text, text) IS
    'Version-checked update for patient_cards. Increments version and returns the updated row. '
    'Raises P0002 if the row version no longer matches p_expected_version (conflict).';

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
