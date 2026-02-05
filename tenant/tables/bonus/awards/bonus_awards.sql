-- =============================================
-- Bonus Awards (Bonus Ödülleri)
-- Oyunculara verilen bonusların kaydı
-- Çevrim takibi ve durum yönetimi
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_awards CASCADE;

CREATE TABLE bonus.bonus_awards (
    id bigserial PRIMARY KEY,

    -- Oyuncu bilgisi
    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Bonus bilgileri
    bonus_rule_id bigint NOT NULL,                -- Bonus kuralı ID (Core DB'den)
    bonus_type_code varchar(50) NOT NULL,         -- Bonus tipi: deposit_match, free_spin, cashback
    trigger_id bigint,                            -- Tetikleyici ID (depozit, kayıt vb.)
    promo_code_id bigint,                         -- Kullanılan promosyon kodu ID
    campaign_id bigint,                           -- Kampanya ID

    -- Değerler
    bonus_amount decimal(18,2) NOT NULL,          -- Bonus tutarı
    currency char(3) NOT NULL,                    -- Para birimi

    -- Çevrim takibi
    wagering_requirement decimal(5,2),            -- Çevrim şartı (x10, x30 vb.)
    wagering_progress decimal(18,2) DEFAULT 0,    -- Tamamlanan çevrim tutarı
    wagering_completed boolean DEFAULT false,     -- Çevrim tamamlandı mı?

    -- Geçerlilik
    expires_at timestamp without time zone,       -- Son kullanma tarihi

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'pending', -- Durum: pending, active, completed, expired, cancelled

    -- Transaction referansı
    tenant_transaction_id bigint,                 -- Oluşturulan transaction ID

    awarded_at timestamp without time zone NOT NULL DEFAULT now(), -- Verilme tarihi
    completed_at timestamp without time zone,     -- Tamamlanma tarihi
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE bonus.bonus_awards IS 'Player bonus awards tracking wagering requirements, progress, and completion status';
