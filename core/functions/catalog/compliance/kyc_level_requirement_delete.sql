-- ================================================================
-- KYC_LEVEL_REQUIREMENT_DELETE: Seviye gereksinimi siler
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.kyc_level_requirement_delete(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.kyc_level_requirements klr WHERE klr.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-level-requirement.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.kyc_level_requirements WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_level_requirement_delete IS 'Deletes a KYC level requirement. Platform Admin only.';
