-- =============================================
-- Tablo: bonus.bonus_awards
-- Açıklama: JSON-driven bonus kural motoru ile
--           oyunculara verilen bonusların kaydı.
--           Çevrim takibi, per-bonus bakiye,
--           stacking ve tam audit trail desteği
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_awards CASCADE;

CREATE TABLE bonus.bonus_awards (
    id BIGSERIAL PRIMARY KEY,

    -- Oyuncu bilgisi
    player_id BIGINT NOT NULL,                         -- Oyuncu ID

    -- Bonus bilgileri (cross-DB referanslar, app-level kontrol)
    bonus_rule_id BIGINT NOT NULL,                     -- Bonus kuralı ID (Bonus DB'den)
    bonus_type_code VARCHAR(50) NOT NULL,              -- Kategori: deposit_match, free_spin, cashback
    bonus_subtype VARCHAR(30),                         -- Alt tip: monetary, freebet, freespin
    promo_code_id BIGINT,                              -- Kullanılan promosyon kodu ID
    campaign_id BIGINT,                                -- Kampanya ID

    -- Değerler
    bonus_amount DECIMAL(18,2) NOT NULL,               -- Bonus tutarı
    currency CHAR(3) NOT NULL,                         -- Para birimi

    -- ═══ JSON-driven Engine Alanları ═══

    -- Rule snapshot (kural değişse bile award orijinal koşulları korur)
    -- Tüm 6 bileşeni içerir: trigger, data, eligibility, reward, usage, target
    rule_snapshot JSONB,

    -- Usage kuralları (Client tarafında enforce edilir)
    -- {"wagering_multiplier":30,"min_combined_count":5,"min_selection_odds":1.65,
    --  "min_total_odds":13.0,"excluded_bet_types":["virtual","live"],
    --  "max_withdrawal_factor":25,"turnover_applies_to":"bonus",
    --  "game_contributions":{"SLOT":100,"LIVE":10,"TABLE":10}}
    usage_criteria JSONB,

    -- Reward hesaplama detayı (audit trail)
    -- {"type":"percentage","source_value":500,"rate":100,"result":500,"capped_at":1000}
    -- {"type":"tiered","source_value":3500,"matched_tier":{"min":2500,"max":4999},"result":500}
    reward_details JSONB,

    -- ═══ Çevrim Takibi ═══
    wagering_target DECIMAL(18,2),                     -- Toplam çevrim hedefi (amount * multiplier)
    wagering_progress DECIMAL(18,2) DEFAULT 0,         -- Tamamlanan çevrim tutarı
    wagering_completed BOOLEAN DEFAULT false,          -- Çevrim tamamlandı mı?

    -- ═══ Kazanç/Çekim Limitleri ═══
    max_withdrawal_amount DECIMAL(18,2),               -- bonus_amount * max_withdrawal_factor
    current_balance DECIMAL(18,2) DEFAULT 0,           -- Per-bonus bakiye takibi (stacking için)

    -- ═══ Geçerlilik ═══
    expires_at TIMESTAMPTZ,                            -- Son kullanma tarihi

    -- ═══ Durum ═══
    -- pending, active, wagering_complete, pending_kyc, completed, expired, cancelled, claimed
    status VARCHAR(20) NOT NULL DEFAULT 'pending',

    -- ═══ Transaction Referansları ═══
    client_transaction_id BIGINT,                      -- Bonus credit transaction ID
    completion_transaction_id BIGINT,                  -- BONUS→REAL dönüşüm transaction ID

    -- ═══ Bonus Request Referansı ═══
    bonus_request_id BIGINT,                           -- Manuel bonus talebi referansı (nullable)

    -- ═══ Admin Audit ═══
    awarded_by BIGINT,                                 -- Manuel award için admin user ID
    cancellation_reason VARCHAR(255),                  -- İptal sebebi
    cancelled_by BIGINT,                               -- İptal eden (admin ID veya NULL=system/player)

    -- ═══ Tarihler ═══
    awarded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),     -- Verilme tarihi
    completed_at TIMESTAMPTZ,                          -- Tamamlanma tarihi
    cancelled_at TIMESTAMPTZ,                          -- İptal tarihi
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.bonus_awards IS 'Player bonus awards with JSON-driven rule engine support, per-bonus balance tracking, wagering progress, and full audit trail';
