-- =============================================
-- Tablo: bonus.provider_bonus_mappings
-- Açıklama: Provider tarafı bonus takibi
--           PP Free Spins, Hub88 Freebets vb.
-- =============================================

CREATE TABLE bonus.provider_bonus_mappings (
    id                    BIGSERIAL       PRIMARY KEY,
    bonus_award_id        BIGINT          NOT NULL,           -- bonus.bonus_awards.id referansı
    provider_code         VARCHAR(50)     NOT NULL,           -- PRAGMATIC, HUB88, EVOLUTION vb.
    provider_bonus_type   VARCHAR(50)     NOT NULL,           -- FREE_SPINS, FREE_CHIPS, TOURNAMENT, FREEBET
    provider_bonus_id     VARCHAR(100)    NOT NULL,           -- Provider bonus/campaign/reward ID'si
    provider_request_id   VARCHAR(100),                       -- PP requestId / Hub88 reward_uuid
    status                VARCHAR(20)     NOT NULL DEFAULT 'active', -- active, completed, cancelled, expired
    provider_data         JSONB,                              -- Provider'a özgü ek veri
    created_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.provider_bonus_mappings IS 'Provider-side bonus tracking for free spins, freebets, and promotions';
