-- ================================================================
-- BONUS_TYPE_GET: Tekil bonus tipi detay
-- ================================================================
-- ID ile bonus tipi sorgular. Aktif kural sayısını da döner.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_type_get(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_type_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', bt.id,
        'clientId', bt.client_id,
        'typeCode', bt.type_code,
        'typeName', bt.type_name,
        'description', bt.description,
        'category', bt.category,
        'valueType', bt.value_type,
        'isActive', bt.is_active,
        'activeRuleCount', (
            SELECT COUNT(*) FROM bonus.bonus_rules br
            WHERE br.bonus_type_id = bt.id AND br.is_active = true
        ),
        'createdAt', bt.created_at,
        'updatedAt', bt.updated_at
    )
    INTO v_result
    FROM bonus.bonus_types bt
    WHERE bt.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-type.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_type_get(BIGINT) IS 'Returns single bonus type detail with active rule count.';
