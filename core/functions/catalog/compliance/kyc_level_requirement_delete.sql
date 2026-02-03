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
    -- Platform Admin kontrolü (SuperAdmin veya Admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code IN ('superadmin', 'admin')
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

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
