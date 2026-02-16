-- ================================================================
-- BONUS_TYPE_LIST: Bonus tipi listesi
-- ================================================================
-- Tenant ve platform seviyesi bonus tiplerini listeler.
-- Filtre: tenant_id, category, is_active.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_type_list(BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION bonus.bonus_type_list(
    p_tenant_id BIGINT DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', bt.id,
            'tenantId', bt.tenant_id,
            'typeCode', bt.type_code,
            'typeName', bt.type_name,
            'category', bt.category,
            'valueType', bt.value_type,
            'isActive', bt.is_active,
            'activeRuleCount', (
                SELECT COUNT(*) FROM bonus.bonus_rules br
                WHERE br.bonus_type_id = bt.id AND br.is_active = true
            )
        ) ORDER BY bt.category, bt.type_code
    ), '[]'::jsonb)
    INTO v_result
    FROM bonus.bonus_types bt
    WHERE (p_tenant_id IS NULL OR bt.tenant_id IS NULL OR bt.tenant_id = p_tenant_id)
      AND (p_category IS NULL OR bt.category = LOWER(TRIM(p_category)))
      AND (p_is_active IS NULL OR bt.is_active = p_is_active);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_type_list(BIGINT, VARCHAR, BOOLEAN) IS 'Lists bonus types filtered by tenant (includes platform-level), category, and active status. Returns active rule count per type.';
