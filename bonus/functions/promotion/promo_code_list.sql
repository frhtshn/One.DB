-- ================================================================
-- PROMO_CODE_LIST: Promo kod listesi
-- ================================================================
-- Filtre: tenant_id, bonus_rule_id, is_active.
-- Platform seviyesi kodlar (tenant_id=NULL) dahil.
-- ================================================================

DROP FUNCTION IF EXISTS promotion.promo_code_list(BIGINT, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION promotion.promo_code_list(
    p_tenant_id BIGINT DEFAULT NULL,
    p_bonus_rule_id BIGINT DEFAULT NULL,
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
            'id', pc.id,
            'tenantId', pc.tenant_id,
            'code', pc.code,
            'promoName', pc.promo_name,
            'bonusRuleId', pc.bonus_rule_id,
            'bonusRuleCode', br.rule_code,
            'maxRedemptions', pc.max_redemptions,
            'currentRedemptions', pc.current_redemptions,
            'maxPerPlayer', pc.max_per_player,
            'validFrom', pc.valid_from,
            'validUntil', pc.valid_until,
            'isActive', pc.is_active
        ) ORDER BY pc.created_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM promotion.promo_codes pc
    JOIN bonus.bonus_rules br ON br.id = pc.bonus_rule_id
    WHERE (p_tenant_id IS NULL OR pc.tenant_id IS NULL OR pc.tenant_id = p_tenant_id)
      AND (p_bonus_rule_id IS NULL OR pc.bonus_rule_id = p_bonus_rule_id)
      AND (p_is_active IS NULL OR pc.is_active = p_is_active);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION promotion.promo_code_list(BIGINT, BIGINT, BOOLEAN) IS 'Lists promotional codes filtered by tenant, bonus rule, and active status. Includes platform-level codes.';
