-- ================================================================
-- PROVIDER_BONUS_MAPPING_GET: Provider bonus eşlemesi getir
-- ================================================================
-- Provider kodu + provider bonus ID ile eşleme arar.
-- Bulunamazsa NULL döner (exception fırlatmaz — backend kontrol eder).
-- Unique index kullanır: idx_provider_bonus_mappings_lookup
-- ================================================================

DROP FUNCTION IF EXISTS bonus.provider_bonus_mapping_get(VARCHAR(50), VARCHAR(100));

CREATE OR REPLACE FUNCTION bonus.provider_bonus_mapping_get(
    p_provider_code     VARCHAR(50),
    p_provider_bonus_id VARCHAR(100)
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id',                 m.id,
        'bonusAwardId',       m.bonus_award_id,
        'providerCode',       m.provider_code,
        'providerBonusType',  m.provider_bonus_type,
        'providerBonusId',    m.provider_bonus_id,
        'providerRequestId',  m.provider_request_id,
        'status',             m.status,
        'providerData',       m.provider_data,
        'createdAt',          m.created_at,
        'updatedAt',          m.updated_at
    ) INTO v_result
    FROM bonus.provider_bonus_mappings m
    WHERE m.provider_code = p_provider_code
      AND m.provider_bonus_id = p_provider_bonus_id;

    -- Bulunamazsa NULL döner (exception yok)
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.provider_bonus_mapping_get(VARCHAR(50), VARCHAR(100))
    IS 'Get provider bonus mapping by provider code and provider bonus ID';
