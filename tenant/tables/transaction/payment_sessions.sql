-- =============================================
-- Tablo: transaction.payment_sessions
-- Açıklama: Ödeme oturumları (deposit/withdrawal)
-- PSP entegrasyonunda session token ile takip.
-- Expire mekanizması ile otomatik temizlik.
-- =============================================

DROP TABLE IF EXISTS transaction.payment_sessions CASCADE;

CREATE TABLE transaction.payment_sessions (
    id                       BIGSERIAL       PRIMARY KEY,

    -- Oturum tanımlayıcı
    session_token            VARCHAR(100)    NOT NULL,            -- Benzersiz token (UUID)

    -- Oyuncu ve işlem bilgileri
    player_id                BIGINT          NOT NULL,            -- FK: auth.players
    session_type             VARCHAR(20)     NOT NULL,            -- DEPOSIT, WITHDRAWAL
    payment_method_id        BIGINT,                              -- Ödeme yöntemi (opsiyonel)
    amount                   DECIMAL(18,8)   NOT NULL,            -- İşlem tutarı
    currency_code            VARCHAR(20)     NOT NULL,            -- Para birimi
    fee_amount               DECIMAL(18,8)   NOT NULL DEFAULT 0,  -- Komisyon tutarı
    net_amount               DECIMAL(18,8),                       -- Net tutar (DEPOSIT: amount, WITHDRAWAL: amount + fee)

    -- Durum
    status                   VARCHAR(20)     NOT NULL DEFAULT 'created', -- created, processing, redirected, pending_approval, completed, failed, cancelled, expired, rejected
    idempotency_key          VARCHAR(100),                        -- Tekrar eden işlemleri önlemek için
    transaction_id           BIGINT,                              -- Bağlı transaction ID (initiate sonrası dolar)

    -- PSP bilgileri
    provider_transaction_id  VARCHAR(100),                        -- PSP referans ID
    provider_redirect_url    TEXT,                                 -- PSP redirect URL
    provider_data            JSONB,                                -- PSP'den gelen ek veri

    -- İstemci bilgileri
    ip_address               INET,                                -- Oyuncu IP'si
    device_type              VARCHAR(20),                          -- DESKTOP, MOBILE, APP
    user_agent               VARCHAR(500),                         -- Tarayıcı user-agent
    metadata                 JSONB,                                -- Ek bilgiler

    -- Zamanlama
    created_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    expires_at               TIMESTAMPTZ     NOT NULL,            -- Oturum son geçerlilik zamanı
    completed_at             TIMESTAMPTZ                           -- Tamamlanma zamanı
);

COMMENT ON TABLE transaction.payment_sessions IS 'Payment session tracking for deposit and withdrawal flows. Stores session lifecycle from creation to completion/expiry.';
