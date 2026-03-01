-- ================================================================
-- JURISDICTION_DELETE: Jurisdiction pasife alır (soft delete)
-- Bağlı kayıt varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_delete(INT);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
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

    -- Bağlı Data Retention Policies kontrolü
    IF EXISTS(SELECT 1 FROM catalog.data_retention_policies drp WHERE drp.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.has-retention-policies';
    END IF;

    -- Bağlı Client Jurisdictions kontrolü (core şemasında)
    IF EXISTS(SELECT 1 FROM core.client_jurisdictions tj WHERE tj.jurisdiction_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.in-use-by-clients';
    END IF;

    -- Soft delete
    UPDATE catalog.jurisdictions SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_delete IS 'Soft-deletes a jurisdiction by setting is_active to false. Fails if related records exist.';
