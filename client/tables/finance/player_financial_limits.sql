-- =============================================
-- Tablo: finance.player_financial_limits
-- Açıklama: Oyuncu genel finansal limitleri
-- Ödeme yönteminden bağımsız, tüm yöntemler
-- genelinde geçerli günlük/haftalık/aylık limitler.
-- Responsible gaming (kayıp/bahis) limitleri dahil.
-- =============================================

DROP TABLE IF EXISTS finance.player_financial_limits CASCADE;

CREATE TABLE finance.player_financial_limits (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL,                                         -- Oyuncu ID

    -- Para birimi (per-currency limitler — fiat/crypto ölçek farkı)
    currency_code VARCHAR(20) NOT NULL DEFAULT 'TRY',                  -- Para birimi kodu: TRY, USD, BTC
    currency_type SMALLINT NOT NULL DEFAULT 1,                         -- 1=Fiat, 2=Crypto

    -- Global para yatırma limitleri (tüm yöntemler geneli)
    daily_deposit_limit DECIMAL(18,8),                                 -- Günlük para yatırma limiti
    weekly_deposit_limit DECIMAL(18,8),                                -- Haftalık para yatırma limiti
    monthly_deposit_limit DECIMAL(18,8),                               -- Aylık para yatırma limiti

    -- Global para çekme limitleri (tüm yöntemler geneli)
    daily_withdrawal_limit DECIMAL(18,8),                              -- Günlük para çekme limiti
    weekly_withdrawal_limit DECIMAL(18,8),                             -- Haftalık para çekme limiti
    monthly_withdrawal_limit DECIMAL(18,8),                            -- Aylık para çekme limiti

    -- Responsible gaming limitleri
    daily_loss_limit DECIMAL(18,8),                                    -- Günlük net kayıp limiti
    weekly_loss_limit DECIMAL(18,8),                                   -- Haftalık net kayıp limiti
    monthly_loss_limit DECIMAL(18,8),                                  -- Aylık net kayıp limiti
    daily_wager_limit DECIMAL(18,8),                                   -- Günlük toplam bahis limiti
    weekly_wager_limit DECIMAL(18,8),                                  -- Haftalık toplam bahis limiti
    monthly_wager_limit DECIMAL(18,8),                                 -- Aylık toplam bahis limiti

    -- Limit tipi
    limit_type VARCHAR(50) NOT NULL DEFAULT 'admin_imposed',           -- self_imposed / admin_imposed

    -- Audit
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE finance.player_financial_limits IS 'Player global financial limits independent of payment methods. Covers deposit/withdrawal caps and responsible gaming limits (loss/wager). Supports self_imposed and admin_imposed types per currency.';
