-- ================================================================
-- RESPONSIBLE_GAMING_POLICY_DELETE: Sorumlu oyun politikasını pasife alır (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_delete(INT);

CREATE OR REPLACE FUNCTION catalog.responsible_gaming_policy_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.responsible-gaming-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.responsible_gaming_policies rgp WHERE rgp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.responsible-gaming-policy.not-found';
    END IF;

    -- Soft delete
    UPDATE catalog.responsible_gaming_policies SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.responsible_gaming_policy_delete IS 'Soft-deletes a responsible gaming policy by setting is_active to false.';
