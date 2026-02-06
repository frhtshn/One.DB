-- ================================================================
-- DATA_RETENTION_POLICY_DELETE: Veri saklama kuralını pasife alır
-- Soft delete: is_active = false (kayıt silinmez)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_delete(INT);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.data_retention_policies drp WHERE drp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.data-retention-policy.not-found';
    END IF;

    -- Soft delete
    UPDATE catalog.data_retention_policies SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_delete IS 'Soft-deletes a data retention policy by setting is_active to false.';
