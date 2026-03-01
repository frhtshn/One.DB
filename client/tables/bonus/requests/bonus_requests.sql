-- =============================================
-- Tablo: bonus.bonus_requests
-- Açıklama: Oyuncu ve BO operatör bonus talepleri.
--           İki akış: oyuncu FE'den talep eder,
--           operatör BO'dan manuel bonus verir.
--           Onay mekanizmalı durum makinesi ile
--           tam yaşam döngüsü takibi.
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_requests CASCADE;

CREATE TABLE bonus.bonus_requests (
    id                  BIGSERIAL       PRIMARY KEY,

    -- Talep bilgileri
    player_id           BIGINT          NOT NULL,               -- Bonus verilecek oyuncu
    request_source      VARCHAR(20)     NOT NULL,               -- player, operator
    request_type        VARCHAR(50)     NOT NULL,               -- Bonus tip kodu (bonus_types.type_code)
    requested_amount    DECIMAL(18,2),                          -- İstenen miktar (operatör set eder, oyuncu NULL)
    currency            VARCHAR(20),                            -- Para birimi (operatör set eder, oyuncu NULL)
    description         TEXT            NOT NULL,               -- Talep açıklaması / gerekçe
    supporting_data     JSONB,                                  -- Ek veri / kanıt

    -- Durum makinesi
    status              VARCHAR(20)     NOT NULL DEFAULT 'pending',  -- pending, assigned, in_progress, on_hold, approved, rejected, cancelled, expired, completed, failed
    priority            SMALLINT        NOT NULL DEFAULT 0,     -- 0=normal, 1=yüksek, 2=acil

    -- Atama bilgileri
    assigned_to_id      BIGINT,                                 -- Atanan reviewer (BO user_id)
    assigned_at         TIMESTAMPTZ,                            -- Atama zamanı

    -- İnceleme / karar bilgileri
    reviewed_by_id      BIGINT,                                 -- Karar veren (BO user_id)
    review_note         VARCHAR(500),                           -- Onay/red açıklaması
    reviewed_at         TIMESTAMPTZ,                            -- Karar zamanı

    -- Onay sonucu
    approved_amount     DECIMAL(18,2),                          -- Onaylanan miktar
    approved_currency   VARCHAR(20),                            -- Onaylanan para birimi
    approved_bonus_type VARCHAR(50),                            -- Onaylanan bonus tipi (değiştirilebilir)
    bonus_rule_id       BIGINT,                                 -- Bağlanan bonus kuralı (Bonus DB ref)
    bonus_award_id      BIGINT,                                 -- Oluşan bonus_awards.id

    -- Talep sahibi ve süre
    requested_by_id     BIGINT,                                 -- BO user_id (operatör talebi için). NULL = oyuncu
    expires_at          TIMESTAMPTZ,                            -- Otomatik expire süresi
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.bonus_requests IS 'Manual bonus requests from players and BO operators. Tracks full lifecycle from request through approval/rejection to bonus award creation.';
