-- ================================================================
-- AML_FLAG_ASSIGN: AML bayrağına soruşturmacı ata
-- ================================================================
-- AML flag'e inceleme yapacak görevliyi atar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_assign(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION kyc.aml_flag_assign(
    p_flag_id     BIGINT,
    p_assigned_to BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_flag_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.flag-required';
    END IF;

    IF p_assigned_to IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.assignee-required';
    END IF;

    -- Flag kontrolü
    IF NOT EXISTS (SELECT 1 FROM kyc.player_aml_flags WHERE id = p_flag_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-aml.not-found';
    END IF;

    UPDATE kyc.player_aml_flags
    SET assigned_to = p_assigned_to,
        assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_flag_id;
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_assign IS 'Assigns an investigator to an AML flag.';
