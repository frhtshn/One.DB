-- =============================================
-- Responsible Gaming Policies (Sorumlu Oyun Politikaları)
-- Jurisdiction bazlı limit ve kısıtlama kuralları
-- Self exclusion ve cooling off gereksinimleri
-- =============================================

DROP TABLE IF EXISTS catalog.responsible_gaming_policies CASCADE;

CREATE TABLE catalog.responsible_gaming_policies (
    id serial PRIMARY KEY,

    jurisdiction_id int NOT NULL UNIQUE,          -- Hangi otorite için (1:1)

    -- Deposit Limit gereksinimleri
    deposit_limit_required boolean NOT NULL DEFAULT false,
    deposit_limit_options jsonb,                  -- Sunulması gereken periyotlar ["DAILY","WEEKLY","MONTHLY"]
    deposit_limit_max_increase_wait_hours int,    -- Limit artışı bekleme süresi

    -- Loss Limit gereksinimleri
    loss_limit_required boolean NOT NULL DEFAULT false,
    loss_limit_options jsonb,

    -- Session Limit gereksinimleri
    session_limit_required boolean NOT NULL DEFAULT false,
    session_limit_max_hours int,                  -- Maksimum tek oturum süresi
    session_break_required boolean DEFAULT false, -- Zorunlu mola var mı?
    session_break_after_hours int,                -- Kaç saat sonra mola
    session_break_duration_minutes int,           -- Mola süresi (dakika)

    -- Reality Check (Gerçeklik kontrolü)
    reality_check_required boolean NOT NULL DEFAULT false,
    reality_check_interval_minutes int,           -- Kaç dakikada bir uyarı

    -- Cooling Off
    cooling_off_available boolean NOT NULL DEFAULT true,
    cooling_off_min_days int DEFAULT 1,           -- Minimum cooling off süresi
    cooling_off_max_days int DEFAULT 42,          -- Maksimum cooling off süresi (6 hafta)
    cooling_off_revocable boolean DEFAULT false,  -- Süre dolmadan iptal edilebilir mi?

    -- Self Exclusion
    self_exclusion_available boolean NOT NULL DEFAULT true,
    self_exclusion_min_months int DEFAULT 6,      -- Minimum self exclusion süresi (ay)
    self_exclusion_permanent_option boolean DEFAULT true, -- Kalıcı seçenek var mı?
    self_exclusion_revocable boolean DEFAULT false,

    -- Merkezi dışlama sistemi
    central_exclusion_system varchar(50),         -- Sistem adı: GAMSTOP, OASIS, ROFUS
    central_exclusion_integration_required boolean DEFAULT false,
    central_exclusion_api_endpoint varchar(255),

    -- Ödeme kısıtlamaları
    anonymous_payments_allowed boolean DEFAULT true,
    crypto_payments_allowed boolean DEFAULT true,
    credit_card_gambling_allowed boolean DEFAULT true,

    -- Para yatırma doğrulaması
    payment_method_ownership_verification boolean DEFAULT false,

    -- Durum
    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.responsible_gaming_policies IS 'Jurisdiction-specific responsible gaming requirements including limits, exclusions, and payment restrictions';
