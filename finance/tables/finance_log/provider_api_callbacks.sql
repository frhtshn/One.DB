-- =============================================
-- Tablo: finance_log.provider_api_callbacks
-- Açıklama: Ödeme provider'larından gelen callback/webhook logları
-- Gateway seviyesi: Tüm tenant'lar için ortak
-- Provider'ın sisteme geri bildirdiği event'ler
-- FINANCE_LOG DB - 14 gün retention (daily partition)
-- =============================================

DROP TABLE IF EXISTS finance_log.provider_api_callbacks CASCADE;

CREATE TABLE finance_log.provider_api_callbacks (
    id bigserial,

    -- Bağlam bilgileri
    tenant_id BIGINT,                                    -- Çözümlenen tenant (NULL olabilir: parse hatası)
    player_id BIGINT,                                    -- Çözümlenen oyuncu (NULL olabilir)
    provider_code VARCHAR(50) NOT NULL,                  -- Provider kodu: PAPARA, PAYFIX, STRIPE
    payment_method_code VARCHAR(100),                    -- Çözümlenen ödeme yöntemi kodu (varsa)

    -- Callback bilgileri
    callback_type VARCHAR(50) NOT NULL,                  -- deposit_confirm, deposit_fail, withdrawal_confirm, withdrawal_fail, chargeback, status_update
    callback_endpoint VARCHAR(500),                      -- Alınan endpoint (/api/callback/papara/deposit)
    raw_payload JSONB NOT NULL,                          -- Ham callback verisi (olduğu gibi)
    parsed_payload JSONB,                                -- Parse edilmiş ve normalize edilmiş veri

    -- İşlem durumu
    processing_status VARCHAR(20) NOT NULL DEFAULT 'received', -- received, processing, processed, failed, rejected, duplicate
    error_code VARCHAR(50),                              -- İşleme hata kodu
    error_message TEXT,                                  -- İşleme hata mesajı

    -- Performans
    processing_time_ms INTEGER,                          -- İşleme süresi (milisaniye)

    -- Provider referansları
    session_token VARCHAR(100),                          -- Payment session token
    external_transaction_id VARCHAR(100),                 -- Provider transaction ID
    amount DECIMAL(18,8),                                -- İşlem tutarı
    currency_code VARCHAR(20),                           -- Para birimi

    -- Güvenlik
    signature_valid BOOLEAN,                             -- İmza doğrulama sonucu
    source_ip INET,                                      -- Kaynak IP adresi

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE finance_log.provider_api_callbacks_default PARTITION OF finance_log.provider_api_callbacks DEFAULT;

COMMENT ON TABLE finance_log.provider_api_callbacks IS 'Inbound callback/webhook logs from payment providers (deposit confirm, withdrawal confirm, chargeback). Gateway-level shared across all tenants. Partitioned daily by created_at. Retention: 14 days.';
