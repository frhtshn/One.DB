-- ================================================================
-- RESPONSIBLE_GAMING_POLICY_DELETE: Sorumlu oyun politikası siler
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.responsible_gaming_policy_delete(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.responsible-gaming-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.responsible_gaming_policies rgp WHERE rgp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.responsible-gaming-policy.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.responsible_gaming_policies WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.responsible_gaming_policy_delete IS 'Deletes a responsible gaming policy. Platform Admin only.';
