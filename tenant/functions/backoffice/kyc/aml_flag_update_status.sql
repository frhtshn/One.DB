-- ================================================================
-- AML_FLAG_UPDATE_STATUS: AML bayrak durumunu güncelle
-- ================================================================
-- Flag durumunu değiştirir (open → investigating → closed).
-- Soruşturma notları ekler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_update_status(BIGINT, VARCHAR, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION kyc.aml_flag_update_status(
    p_flag_id        BIGINT,
    p_new_status     VARCHAR(30),
    p_investigated_by BIGINT DEFAULT NULL,
    p_notes          TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status VARCHAR(30);
BEGIN
    IF p_flag_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.flag-required';
    END IF;

    IF p_new_status IS NULL OR TRIM(p_new_status) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.status-required';
    END IF;

    -- Mevcut durumu al
    SELECT status INTO v_old_status
    FROM kyc.player_aml_flags
    WHERE id = p_flag_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-aml.not-found';
    END IF;

    IF v_old_status = p_new_status THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.status-unchanged';
    END IF;

    UPDATE kyc.player_aml_flags
    SET status = p_new_status,
        investigated_by = COALESCE(p_investigated_by, investigated_by),
        investigation_started_at = CASE
            WHEN p_new_status = 'investigating' AND investigation_started_at IS NULL THEN NOW()
            ELSE investigation_started_at
        END,
        investigation_notes = CASE
            WHEN p_notes IS NOT NULL THEN COALESCE(investigation_notes || E'\n', '') || p_notes
            ELSE investigation_notes
        END,
        closed_at = CASE WHEN p_new_status = 'closed' THEN NOW() ELSE closed_at END,
        updated_at = NOW()
    WHERE id = p_flag_id;
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_update_status IS 'Updates AML flag status with investigation tracking. Notes are appended (not replaced).';
