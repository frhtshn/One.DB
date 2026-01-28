-- ================================================================
-- TENANT_LANGUAGE_UPSERT: Tenant dil ekle/güncelle
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_language_upsert(BIGINT, CHAR(2), BOOLEAN);

CREATE OR REPLACE FUNCTION core.tenant_language_upsert(
    p_tenant_id BIGINT,
    p_language_code CHAR(2),
    p_is_enabled BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validations
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM catalog.languages WHERE language_code = p_language_code AND is_active = TRUE) THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.language.not-found';
    END IF;

    -- Upsert Logic
    IF EXISTS (SELECT 1 FROM core.tenant_languages WHERE tenant_id = p_tenant_id AND language_code = p_language_code) THEN
        UPDATE core.tenant_languages
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE tenant_id = p_tenant_id AND language_code = p_language_code;
    ELSE
        INSERT INTO core.tenant_languages (tenant_id, language_code, is_enabled)
        VALUES (p_tenant_id, p_language_code, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.tenant_language_upsert(BIGINT, CHAR(2), BOOLEAN) IS 'Assigns or updates a supported language for a tenant.';
