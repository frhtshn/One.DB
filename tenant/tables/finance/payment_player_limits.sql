-- =============================================
-- Payment Player Limits (Oyuncu Ödeme Limitleri)
-- Oyuncu bazında özel ödeme limitleri
-- Sorumlu oyun veya admin tarafından belirlenir
-- =============================================

DROP TABLE IF EXISTS finance.payment_player_limits CASCADE;

CREATE TABLE finance.payment_player_limits (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Denormalize edilmiş alanlar
    payment_method_id bigint NOT NULL,            -- Ödeme yöntemi ID
    payment_method_code varchar(100) NOT NULL,    -- Yöntem kodu

    -- Para yatırma limitleri (oyuncuya özel)
    min_deposit decimal(18,2),                    -- Minimum para yatırma
    max_deposit decimal(18,2),                    -- Maksimum para yatırma

    -- Para çekme limitleri (oyuncuya özel)
    min_withdrawal decimal(18,2),                 -- Minimum para çekme
    max_withdrawal decimal(18,2),                 -- Maksimum para çekme

    -- Periyodik limitler
    daily_deposit_limit decimal(18,2),            -- Günlük para yatırma limiti
    daily_withdrawal_limit decimal(18,2),         -- Günlük para çekme limiti
    monthly_deposit_limit decimal(18,2),          -- Aylık para yatırma limiti
    monthly_withdrawal_limit decimal(18,2),       -- Aylık para çekme limiti

    -- Limit tipi
    limit_type varchar(50),                       -- Tip: self_imposed, responsible_gaming, admin_imposed

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
