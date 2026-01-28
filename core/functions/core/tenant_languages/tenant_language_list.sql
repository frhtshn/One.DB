-- ================================================================
-- TENANT_LANGUAGE_LIST: Tenant dillerini listeler
-- Default language bilgisini isDefault olarak işaretler.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_language_list(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_language_list(p_tenant_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_default_language CHAR(2);
    v_result JSONB;
BEGIN
    -- Get default language
    SELECT default_language INTO v_default_language FROM core.tenants WHERE id = p_tenant_id;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tl.id,
            'tenantId', tl.tenant_id,
            'code', tl.language_code,
            'name', l.language_name,
            'isEnabled', tl.is_enabled,
            'isDefault', (tl.language_code = v_default_language),
            'createdAt', tl.created_at,
            'updatedAt', tl.updated_at
        ) ORDER BY (tl.language_code = v_default_language) DESC, tl.is_enabled DESC, l.language_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_languages tl
    JOIN catalog.languages l ON l.language_code = tl.language_code
    WHERE tl.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_language_list(BIGINT) IS 'Lists all assigned languages for a tenant.';
