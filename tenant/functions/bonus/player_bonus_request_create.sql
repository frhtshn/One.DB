-- ================================================================
-- PLAYER_BONUS_REQUEST_CREATE: Oyuncu bonus talebi oluştur
-- ================================================================
-- Oyuncu FE'den bonus tipi seçip talep eder.
-- Tam uygunluk ve cooldown kontrolü yapar:
-- 1. Setting is_requestable kontrolü
-- 2. Grup/kategori uygunluk filtresi (OR mantığı)
-- 3. Pending talep limiti
-- 4. Onay sonrası cooldown
-- 5. Red sonrası cooldown
-- Tüm kontroller OK ise bonus_request_create() çağrılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.player_bonus_request_create(BIGINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION bonus.player_bonus_request_create(
    p_player_id     BIGINT,
    p_request_type  VARCHAR(50),
    p_description   TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_setting           RECORD;
    v_player_groups     JSONB;
    v_player_category   VARCHAR(50);
    v_player_category_level INT;
    v_player_max_group_level INT;
    v_is_eligible       BOOLEAN;
    v_pending_count     INT;
    v_last_reviewed_at  TIMESTAMPTZ;
    v_request_id        BIGINT;
BEGIN
    -- Zorunlu alan kontrolü
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.player-required';
    END IF;

    IF p_request_type IS NULL OR p_request_type = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.type-required';
    END IF;

    IF p_description IS NULL OR p_description = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.description-required';
    END IF;

    -- 1. Setting kontrolü: is_requestable = true
    SELECT * INTO v_setting
    FROM bonus.bonus_request_settings
    WHERE bonus_type_code = p_request_type
      AND is_active = true;

    IF v_setting IS NULL OR NOT v_setting.is_requestable THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.type-not-requestable';
    END IF;

    -- Açıklama uzunluk kontrolü
    IF LENGTH(p_description) > v_setting.max_description_length THEN
        p_description := LEFT(p_description, v_setting.max_description_length);
    END IF;

    -- 2. Grup/kategori uygunluk filtresi (OR mantığı)
    IF v_setting.eligible_groups IS NOT NULL
       OR v_setting.eligible_categories IS NOT NULL
       OR v_setting.min_group_level IS NOT NULL
       OR v_setting.min_category_level IS NOT NULL
    THEN
        -- Oyuncu segmentation bilgilerini al
        SELECT COALESCE(pc.category_code, ''), COALESCE(pc.level, 0)
        INTO v_player_category, v_player_category_level
        FROM auth.player_classification cls
        JOIN auth.player_categories pc ON pc.id = cls.player_category_id
        WHERE cls.player_id = p_player_id
        LIMIT 1;

        SELECT COALESCE(jsonb_agg(pg.group_code), '[]'::JSONB), COALESCE(MAX(pg.level), 0)
        INTO v_player_groups, v_player_max_group_level
        FROM auth.player_classification cls
        JOIN auth.player_groups pg ON pg.id = cls.player_group_id
        WHERE cls.player_id = p_player_id
          AND cls.player_group_id IS NOT NULL;

        v_is_eligible := false;

        -- Kod bazlı grup kontrolü
        IF v_setting.eligible_groups IS NOT NULL AND v_player_groups IS NOT NULL THEN
            IF EXISTS (
                SELECT 1
                FROM jsonb_array_elements_text(v_setting.eligible_groups) eg
                WHERE eg.value IN (SELECT jsonb_array_elements_text(v_player_groups))
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

        IF NOT v_is_eligible THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.bonus-request.player-not-eligible';
        END IF;
    END IF;

    -- 3. Pending talep limiti
    SELECT COUNT(*) INTO v_pending_count
    FROM bonus.bonus_requests
    WHERE player_id = p_player_id
      AND request_type = p_request_type
      AND status IN ('pending', 'assigned', 'in_progress', 'on_hold');

    IF v_pending_count >= v_setting.max_pending_per_player THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.pending-exists';
    END IF;

    -- 4. Onay sonrası cooldown
    SELECT reviewed_at INTO v_last_reviewed_at
    FROM bonus.bonus_requests
    WHERE player_id = p_player_id
      AND request_type = p_request_type
      AND status = 'completed'
    ORDER BY reviewed_at DESC
    LIMIT 1;

    IF v_last_reviewed_at IS NOT NULL
       AND v_last_reviewed_at + (v_setting.cooldown_after_approved_days || ' days')::INTERVAL > NOW()
    THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.cooldown-after-approved';
    END IF;

    -- 5. Red sonrası cooldown
    SELECT reviewed_at INTO v_last_reviewed_at
    FROM bonus.bonus_requests
    WHERE player_id = p_player_id
      AND request_type = p_request_type
      AND status = 'rejected'
    ORDER BY reviewed_at DESC
    LIMIT 1;

    IF v_last_reviewed_at IS NOT NULL
       AND v_last_reviewed_at + (v_setting.cooldown_after_rejected_days || ' days')::INTERVAL > NOW()
    THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.cooldown-after-rejected';
    END IF;

    -- 6. Tüm kontroller OK → talep oluştur
    v_request_id := bonus.bonus_request_create(
        p_player_id         := p_player_id,
        p_request_source    := 'player',
        p_request_type      := p_request_type,
        p_description       := p_description,
        p_requested_amount  := NULL,
        p_currency          := NULL,
        p_supporting_data   := NULL,
        p_priority          := 0::SMALLINT,
        p_requested_by_id   := NULL,
        p_expires_in_hours  := 72
    );

    RETURN v_request_id;
END;
$$;

COMMENT ON FUNCTION bonus.player_bonus_request_create IS 'Player-facing bonus request creation with full eligibility and cooldown validation. Checks requestability, group/category eligibility (OR logic), pending limits, and cooldown periods before creating.';
