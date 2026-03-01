-- =============================================
-- Tablo: finance_log.provider_api_requests
-- Açıklama: Ödeme provider'larına yapılan API çağrı logları
-- Gateway seviyesi: Tüm tenant'lar için ortak
-- Deposit, withdrawal, status check vb. istekler
-- FINANCE_LOG DB - 14 gün retention (daily partition)
-- =============================================

DROP TABLE IF EXISTS finance_log.provider_api_requests CASCADE;

CREATE TABLE finance_log.provider_api_requests (
    id bigserial,

    -- Bağlam bilgileri
    tenant_id BIGINT NOT NULL,                           -- Hangi tenant adına çağrı yapıldı
    player_id BIGINT,                                    -- İlgili oyuncu (varsa)
    provider_code VARCHAR(50) NOT NULL,                  -- Provider kodu: PAPARA, PAYFIX, STRIPE
    payment_method_code VARCHAR(100),                    -- İlgili ödeme yöntemi kodu (varsa)

    -- İstek bilgileri
    request_id UUID DEFAULT gen_random_uuid(),           -- Korelasyon ID (distributed tracing)
    action_type VARCHAR(50) NOT NULL,                    -- deposit, withdrawal, status_check, refund, callback_verify
    api_endpoint VARCHAR(500) NOT NULL,                  -- Çağrılan endpoint URL
    api_method VARCHAR(10) NOT NULL DEFAULT 'POST',      -- HTTP method (GET, POST, PUT)
    request_headers JSONB,                               -- İstek header'ları (hassas bilgiler maskelenmeli)
    request_payload JSONB,                               -- İstek gövdesi

    -- Yanıt bilgileri
    response_payload JSONB,                              -- Yanıt gövdesi
    http_status_code SMALLINT,                           -- HTTP durum kodu (200, 400, 500, vb.)
    status VARCHAR(20) NOT NULL DEFAULT 'pending',       -- pending, success, failed, timeout, error
    error_code VARCHAR(50),                              -- Provider hata kodu
    error_message TEXT,                                  -- Hata mesajı

    -- Performans
    response_time_ms INTEGER,                            -- Yanıt süresi (milisaniye)

    -- Finansal bağlam (debug amaçlı)
    session_token VARCHAR(100),                          -- Payment session token
    external_transaction_id VARCHAR(100),                 -- Provider transaction ID
    amount DECIMAL(18,8),                                -- İşlem tutarı (varsa)
    currency_code VARCHAR(20),                           -- Para birimi

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE finance_log.provider_api_requests_default PARTITION OF finance_log.provider_api_requests DEFAULT;

COMMENT ON TABLE finance_log.provider_api_requests IS 'Outbound API call logs to payment/finance providers (deposit, withdrawal, status check, refund). Gateway-level shared across all tenants. Partitioned daily by created_at. Retention: 14 days.';
