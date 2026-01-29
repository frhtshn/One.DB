-- =============================================
-- Player Limits (Oyuncu Kendi Limitleri)
-- Sorumlu oyun kapsamında oyuncunun belirlediği limitler
-- Deposit, Loss, Wager, Session limitleri
-- =============================================

DROP TABLE IF EXISTS kyc.player_limits CASCADE;

CREATE TABLE kyc.player_limits (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Limit tipi
    limit_type varchar(30) NOT NULL,              -- Limit türü
    -- DEPOSIT: Para yatırma limiti
    -- LOSS: Kayıp limiti
    -- WAGER: Bahis limiti
    -- SESSION: Oturum süresi limiti (dakika)

    -- Limit periyodu
    limit_period varchar(20) NOT NULL,            -- Periyot
    -- DAILY: Günlük
    -- WEEKLY: Haftalık
    -- MONTHLY: Aylık

    -- Limit değeri
    limit_value decimal(18,2) NOT NULL,           -- Limit tutarı veya dakika
    currency_code character(3),                   -- Para birimi (SESSION için NULL)

    -- Durum ve tarihler
    status varchar(20) NOT NULL DEFAULT 'ACTIVE', -- Durum
    -- ACTIVE: Aktif
    -- PENDING_INCREASE: Artış beklemede
    -- EXPIRED: Süresi dolmuş

    -- Limit değişiklik kontrolü
    pending_value decimal(18,2),                  -- Bekleyen yeni değer (artış için)
    pending_activation_at timestamp,              -- Artışın aktif olacağı tarih

    -- Kim belirledi
    set_by varchar(20) NOT NULL DEFAULT 'PLAYER', -- Belirleyen
    -- PLAYER: Oyuncu
    -- ADMIN: Admin/Destek
    -- SYSTEM: Sistem otomatik

    starts_at timestamp NOT NULL DEFAULT now(),   -- Limitin başlangıç tarihi
    expires_at timestamp,                         -- Limitin bitiş tarihi (NULL = süresiz)

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_limits IS 'Player-defined responsible gaming limits for deposits, losses, wagers, and session time';
