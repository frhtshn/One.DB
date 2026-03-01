-- ================================================================
-- PLAYER_REQUESTABLE_BONUS_TYPES: Oyuncunun talep edebileceği bonus tipleri
-- ================================================================
-- FE-facing fonksiyon. is_requestable = true ayarları alır,
-- oyuncunun grup/kategori uygunluğunu kontrol eder,
-- cooldown durumunu hesaplar, lokalize display_name ve
-- rules_content döner. Çevrim ön bilgisi dahil.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.player_requestable_bonus_types(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.player_requestable_bonus_types(
    p_player_id BIGINT,
    p_language  VARCHAR(10) DEFAULT 'tr'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_groups     JSONB;
    v_player_group_codes JSONB;
    v_player_category   VARCHAR(50);
    v_player_category_level INT;
    v_player_max_group_level INT;
    v_items             JSONB := '[]'::JSONB;
    v_setting           RECORD;
    v_is_eligible       BOOLEAN;
    v_is_available      BOOLEAN;
    v_next_available_at TIMESTAMPTZ;
    v_reason            VARCHAR(50);
    v_display_name      TEXT;
    v_rules_html        TEXT;
    v_has_wagering      BOOLEAN;
    v_wagering_multiplier DECIMAL;
    v_wagering_expires  INT;
    v_last_reviewed_at  TIMESTAMPTZ;
    v_pending_count     INT;
BEGIN
    -- Oyuncu segmentation bilgilerini al
    SELECT
        COALESCE(pc.category_code, ''),
        COALESCE(pc.level, 0)
    INTO v_player_category, v_player_category_level
    FROM auth.player_classification cls
    JOIN auth.player_categories pc ON pc.id = cls.player_category_id
    WHERE cls.player_id = p_player_id
    LIMIT 1;

    -- Oyuncunun grup kodları ve max level'ı
    SELECT
        COALESCE(jsonb_agg(pg.group_code), '[]'::JSONB),
        COALESCE(MAX(pg.level), 0)
    INTO v_player_group_codes, v_player_max_group_level
    FROM auth.player_classification cls
    JOIN auth.player_groups pg ON pg.id = cls.player_group_id
    WHERE cls.player_id = p_player_id
      AND cls.player_group_id IS NOT NULL;

    -- Her aktif ve talep edilebilir ayar için kontrol
    FOR v_setting IN
        SELECT *
        FROM bonus.bonus_request_settings
        WHERE is_requestable = true
          AND is_active = true
        ORDER BY display_order, bonus_type_code
    LOOP
        -- Uygunluk kontrolü (OR mantığı)
        v_is_eligible := true;

        -- Filtre tanımlıysa kontrol et
        IF v_setting.eligible_groups IS NOT NULL
           OR v_setting.eligible_categories IS NOT NULL
           OR v_setting.min_group_level IS NOT NULL
           OR v_setting.min_category_level IS NOT NULL
        THEN
            v_is_eligible := false;

            -- Kod bazlı grup kontrolü
            IF v_setting.eligible_groups IS NOT NULL AND v_player_group_codes IS NOT NULL THEN
                IF EXISTS (
                    SELECT 1
                    FROM jsonb_array_elements_text(v_setting.eligible_groups) eg
                    WHERE eg.value IN (SELECT jsonb_array_elements_text(v_player_group_codes))
                ) THEN
                    v_is_eligible := true;
                END IF;
            END IF;

            -- Kod bazlı kategori kontrolü
            IF NOT v_is_eligible AND v_setting.eligible_categories IS NOT NULL AND v_player_category <> '' THEN
                IF EXISTS (
                    SELECT 1
                    FROM jsonb_array_elements_text(v_setting.eligible_categories) ec
                    WHERE ec.value = v_player_category
                ) THEN
                    v_is_eligible := true;
                END IF;
            END IF;

            -- Level bazlı grup kontrolü
            IF NOT v_is_eligible AND v_setting.min_group_level IS NOT NULL THEN
                IF v_player_max_group_level >= v_setting.min_group_level THEN
                    v_is_eligible := true;
                END IF;
            END IF;

            -- Level bazlı kategori kontrolü
            IF NOT v_is_eligible AND v_setting.min_category_level IS NOT NULL THEN
                IF v_player_category_level >= v_setting.min_category_level THEN
                    v_is_eligible := true;
                END IF;
            END IF;
        END IF;

        -- Uygun değilse atla
        IF NOT v_is_eligible THEN
            CONTINUE;
        END IF;

        -- Cooldown ve availability kontrolü
        v_is_available := true;
        v_next_available_at := NULL;
        v_reason := NULL;

        -- Pending talep kontrolü
        SELECT COUNT(*) INTO v_pending_count
        FROM bonus.bonus_requests
        WHERE player_id = p_player_id
          AND request_type = v_setting.bonus_type_code
          AND status IN ('pending', 'assigned', 'in_progress', 'on_hold');

        IF v_pending_count >= v_setting.max_pending_per_player THEN
            v_is_available := false;
            v_reason := 'pending_exists';
        END IF;

        -- Onay sonrası cooldown
        IF v_is_available THEN
            SELECT reviewed_at INTO v_last_reviewed_at
            FROM bonus.bonus_requests
            WHERE player_id = p_player_id
              AND request_type = v_setting.bonus_type_code
              AND status = 'completed'
            ORDER BY reviewed_at DESC
            LIMIT 1;

            IF v_last_reviewed_at IS NOT NULL
               AND v_last_reviewed_at + (v_setting.cooldown_after_approved_days || ' days')::INTERVAL > NOW()
            THEN
                v_is_available := false;
                v_next_available_at := v_last_reviewed_at + (v_setting.cooldown_after_approved_days || ' days')::INTERVAL;
                v_reason := 'cooldown_after_approved';
            END IF;
        END IF;

        -- Red sonrası cooldown
        IF v_is_available THEN
            SELECT reviewed_at INTO v_last_reviewed_at
            FROM bonus.bonus_requests
            WHERE player_id = p_player_id
              AND request_type = v_setting.bonus_type_code
              AND status = 'rejected'
            ORDER BY reviewed_at DESC
            LIMIT 1;

            IF v_last_reviewed_at IS NOT NULL
               AND v_last_reviewed_at + (v_setting.cooldown_after_rejected_days || ' days')::INTERVAL > NOW()
            THEN
                v_is_available := false;
                v_next_available_at := v_last_reviewed_at + (v_setting.cooldown_after_rejected_days || ' days')::INTERVAL;
                v_reason := 'cooldown_after_rejected';
            END IF;
        END IF;

        -- Lokalize display_name ve rules_content
        v_display_name := COALESCE(
            v_setting.display_name ->> p_language,
            v_setting.display_name ->> 'en',
            v_setting.bonus_type_code
        );

        v_rules_html := NULL;
        IF v_setting.rules_content IS NOT NULL THEN
            v_rules_html := COALESCE(
                v_setting.rules_content ->> p_language,
                v_setting.rules_content ->> 'en'
            );
        END IF;

        -- Çevrim ön bilgisi
        v_has_wagering := false;
        v_wagering_multiplier := NULL;
        v_wagering_expires := NULL;

        IF v_setting.default_usage_criteria IS NOT NULL THEN
            v_wagering_multiplier := (v_setting.default_usage_criteria ->> 'wagering_multiplier')::DECIMAL;
            v_wagering_expires := (v_setting.default_usage_criteria ->> 'expires_in_days')::INT;
            IF v_wagering_multiplier IS NOT NULL AND v_wagering_multiplier > 0 THEN
                v_has_wagering := true;
            END IF;
        END IF;

        -- Sonuç dizisine ekle
        v_items := v_items || jsonb_build_object(
            'typeCode', v_setting.bonus_type_code,
            'displayName', v_display_name,
            'rulesHtml', v_rules_html,
            'available', v_is_available,
            'nextAvailableAt', v_next_available_at,
            'reason', v_reason,
            'hasWagering', v_has_wagering,
            'wageringMultiplier', v_wagering_multiplier,
            'wageringExpiresInDays', v_wagering_expires
        );
    END LOOP;

    RETURN v_items;
END;
$$;

COMMENT ON FUNCTION bonus.player_requestable_bonus_types IS 'Returns requestable bonus types for a player, filtered by eligibility (group/category) and cooldown status. Includes localized display names, rules HTML, and wagering info.';
