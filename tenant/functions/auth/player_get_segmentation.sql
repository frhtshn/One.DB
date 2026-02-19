-- ================================================================
-- PLAYER_GET_SEGMENTATION: Oyuncu segmentasyon bilgisi
-- ================================================================
-- Bonus eligibility değerlendirmesi için tek giriş noktası.
-- Backend bu JSONB'yi alır, eligibility_criteria koşullarını
-- bu veriye karşı değerlendirir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_get_segmentation(BIGINT);

CREATE OR REPLACE FUNCTION auth.player_get_segmentation(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
    v_category_code VARCHAR;
    v_category_level INT;
    v_groups JSONB;
    v_group_codes JSONB;
    v_group_max_level INT;
    v_country CHAR(2);
    v_kyc_status VARCHAR;
    v_registered_at TIMESTAMPTZ;
BEGIN
    -- Oyuncu temel bilgileri
    SELECT p.registered_at
    INTO v_registered_at
    FROM auth.players p
    WHERE p.id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.player-classification.player-not-found';
    END IF;

    -- Ülke kodu (profil tablosundan)
    SELECT pp.country_code
    INTO v_country
    FROM profile.player_profile pp
    WHERE pp.player_id = p_player_id;

    -- KYC durumu
    SELECT pkc.current_status
    INTO v_kyc_status
    FROM kyc.player_kyc_cases pkc
    WHERE pkc.player_id = p_player_id
    ORDER BY pkc.updated_at DESC
    LIMIT 1;

    -- Kategori bilgisi
    SELECT pc.category_code, pc.level
    INTO v_category_code, v_category_level
    FROM auth.player_classification pcl
    JOIN auth.player_categories pc ON pc.id = pcl.player_category_id
    WHERE pcl.player_id = p_player_id
      AND pcl.player_category_id IS NOT NULL
      AND pcl.player_group_id IS NULL
    LIMIT 1;

    -- Grup bilgileri
    SELECT
        COALESCE(jsonb_agg(pg.group_code ORDER BY pg.level DESC), '[]'::jsonb),
        MAX(pg.level)
    INTO v_group_codes, v_group_max_level
    FROM auth.player_classification pcl
    JOIN auth.player_groups pg ON pg.id = pcl.player_group_id
    WHERE pcl.player_id = p_player_id
      AND pcl.player_group_id IS NOT NULL;

    -- Sonuç JSONB'si
    v_result := jsonb_build_object(
        'playerId', p_player_id,
        'category', CASE
            WHEN v_category_code IS NOT NULL THEN jsonb_build_object('code', v_category_code, 'level', v_category_level)
            ELSE NULL
        END,
        'categoryLevel', v_category_level,
        'groups', v_group_codes,
        'groupCodes', v_group_codes,
        'groupMaxLevel', v_group_max_level,
        'country', v_country,
        'kycStatus', COALESCE(v_kyc_status, 'not_started'),
        'accountAgeDays', EXTRACT(DAY FROM NOW() - v_registered_at)::INT,
        'registeredAt', v_registered_at
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION auth.player_get_segmentation IS 'Returns player segmentation data for bonus eligibility evaluation. Single entry point for backend rule engine.';
