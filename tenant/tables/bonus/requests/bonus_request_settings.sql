-- =============================================
-- Tablo: bonus.bonus_request_settings
-- Açıklama: Tenant bazlı bonus talep ayarları.
--           Hangi bonus tiplerinin talep edilebilir
--           olduğunu, uygunluk filtrelerini,
--           cooldown sürelerini ve lokalize
--           görüntüleme bilgilerini tutar.
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_request_settings CASCADE;

CREATE TABLE bonus.bonus_request_settings (
    id                          BIGSERIAL       PRIMARY KEY,

    -- Bonus tip referansı (Bonus DB'den cross-DB)
    bonus_type_code             VARCHAR(50)     NOT NULL,

    -- Lokalize görüntüleme bilgileri
    display_name                JSONB           NOT NULL,       -- {"tr":"Kayıp Bonusu","en":"Loss Bonus"}
    rules_content               JSONB,                          -- {"tr":"<p>...</p>","en":"<p>...</p>"} — HTML rich text

    -- Talep edilebilirlik
    is_requestable              BOOLEAN         NOT NULL DEFAULT false,

    -- Uygunluk filtreleri (OR mantığı — herhangi biri sağlanırsa uygun)
    eligible_groups             JSONB,                          -- ["high_rollers","vip"] — kod bazlı
    eligible_categories         JSONB,                          -- ["gold","platinum"] — kod bazlı
    min_group_level             INT,                            -- Level bazlı: 30 → level 30+ gruplar uygun
    min_category_level          INT,                            -- Level bazlı: 30 → gold(30)+ kategoriler uygun

    -- Cooldown süreleri (gün)
    cooldown_after_approved_days INT            NOT NULL DEFAULT 30,
    cooldown_after_rejected_days INT            NOT NULL DEFAULT 3,

    -- Talep limitleri
    max_pending_per_player      INT             NOT NULL DEFAULT 1,
    max_description_length      INT             NOT NULL DEFAULT 500,

    -- Minimum depozit koşulu
    require_minimum_deposit     BOOLEAN         NOT NULL DEFAULT false,
    min_deposit_amount          DECIMAL(18,2),

    -- Varsayılan çevrim şartı (operatör override edebilir)
    default_usage_criteria      JSONB,                          -- {"wagering_multiplier":30,"expires_in_days":30,...}

    -- Sıralama ve durum
    display_order               INT             NOT NULL DEFAULT 0,
    is_active                   BOOLEAN         NOT NULL DEFAULT true,
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.bonus_request_settings IS 'Per-tenant bonus request settings. Defines which bonus types are requestable by players, eligibility by player groups/categories, cooldown periods, request limits, localized display names and HTML rules content.';
