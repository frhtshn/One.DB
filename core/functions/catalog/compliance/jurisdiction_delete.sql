-- ================================================================
-- JURISDICTION_DELETE: Jurisdiction siler
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- Bağlı kayıt varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_delete(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_delete(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Bağlı KYC Policy kontrolü
    IF EXISTS(SELECT 1 FROM catalog.kyc_policies kp WHERE kp.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.has-kyc-policy';
    END IF;

    -- Bağlı KYC Document Requirements kontrolü
    IF EXISTS(SELECT 1 FROM catalog.kyc_document_requirements kdr WHERE kdr.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.has-document-requirements';
    END IF;

    -- Bağlı KYC Level Requirements kontrolü
    IF EXISTS(SELECT 1 FROM catalog.kyc_level_requirements klr WHERE klr.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.has-level-requirements';
    END IF;

    -- Bağlı Responsible Gaming Policy kontrolü
    IF EXISTS(SELECT 1 FROM catalog.responsible_gaming_policies rgp WHERE rgp.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.has-gaming-policy';
    END IF;

    -- Bağlı Tenant Jurisdictions kontrolü (core şemasında)
    IF EXISTS(SELECT 1 FROM core.tenant_jurisdictions tj WHERE tj.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.in-use-by-tenants';
    END IF;

    -- Sil
    DELETE FROM catalog.jurisdictions WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_delete IS 'Deletes a jurisdiction. Platform Admin only. Fails if related records exist.';
