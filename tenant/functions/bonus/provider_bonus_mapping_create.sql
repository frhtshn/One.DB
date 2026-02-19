-- ================================================================
-- PROVIDER_BONUS_MAPPING_CREATE: Provider bonus eşlemesi oluştur
-- ================================================================
-- Provider tarafında oluşturulan bonus'u (free spin, freebet vb.)
-- internal bonus_award ile eşleştirir.
-- PP: campaignId + requestId, Hub88: campaign_uuid + reward_uuid
-- ================================================================

DROP FUNCTION IF EXISTS bonus.provider_bonus_mapping_create(
    BIGINT, VARCHAR(50), VARCHAR(50), VARCHAR(100), VARCHAR(100), TEXT
);

CREATE OR REPLACE FUNCTION bonus.provider_bonus_mapping_create(
    p_bonus_award_id        BIGINT,
    p_provider_code         VARCHAR(50),
    p_provider_bonus_type   VARCHAR(50),
    p_provider_bonus_id     VARCHAR(100),
    p_provider_request_id   VARCHAR(100) DEFAULT NULL,
    p_provider_data         TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_id BIGINT;
    v_provider_data JSONB;
BEGIN
    -- ------------------------------------------------
    -- Zorunlu alan kontrolleri
    -- ------------------------------------------------
    IF p_bonus_award_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.bonus-mapping.award-required');
    END IF;

    IF p_provider_code IS NULL OR TRIM(p_provider_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.bonus-mapping.provider-required');
    END IF;

    IF p_provider_bonus_type IS NULL OR TRIM(p_provider_bonus_type) = ''
       OR p_provider_bonus_id IS NULL OR TRIM(p_provider_bonus_id) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.bonus-mapping.data-required');
    END IF;

    -- ------------------------------------------------
    -- Provider data parse
    -- ------------------------------------------------
    v_provider_data := CASE
        WHEN p_provider_data IS NOT NULL AND TRIM(p_provider_data) <> ''
        THEN p_provider_data::JSONB
        ELSE NULL
    END;

    -- ------------------------------------------------
    -- INSERT
    -- ------------------------------------------------
    INSERT INTO bonus.provider_bonus_mappings (
        bonus_award_id,
        provider_code,
        provider_bonus_type,
        provider_bonus_id,
        provider_request_id,
        provider_data,
        created_at,
        updated_at
    ) VALUES (
        p_bonus_award_id,
        TRIM(p_provider_code),
        TRIM(p_provider_bonus_type),
        TRIM(p_provider_bonus_id),
        NULLIF(TRIM(p_provider_request_id), ''),
        v_provider_data,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION bonus.provider_bonus_mapping_create(BIGINT, VARCHAR(50), VARCHAR(50), VARCHAR(100), VARCHAR(100), TEXT)
    IS 'Create provider-side bonus mapping for free spins, freebets, and promotions';
