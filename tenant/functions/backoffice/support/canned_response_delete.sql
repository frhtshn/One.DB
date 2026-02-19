-- ================================================================
-- CANNED_RESPONSE_DELETE: Hazır yanıt sil (soft delete)
-- ================================================================
-- Hazır yanıt şablonunu soft delete ile pasif yapar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.canned_response_delete(BIGINT);

CREATE OR REPLACE FUNCTION support.canned_response_delete(
    p_response_id   BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_response  RECORD;
BEGIN
    -- Kayıt mevcut mu kontrol
    SELECT id, is_active INTO v_response
    FROM support.canned_responses
    WHERE id = p_response_id;

    IF v_response.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.canned-response-not-found';
    END IF;

    IF v_response.is_active = false THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.canned-response-already-deleted';
    END IF;

    -- Soft delete
    UPDATE support.canned_responses
    SET is_active = false, updated_at = NOW()
    WHERE id = p_response_id;
END;
$$;

COMMENT ON FUNCTION support.canned_response_delete IS 'Soft deletes a canned response template by setting is_active = false.';
