-- =============================================
-- Tablo: affiliate_log.api_requests
-- Açıklama: Affiliate API istek logları
-- Panel ve API üzerinden gelen istekler
-- Performans ve hata analizi için
-- =============================================

DROP TABLE IF EXISTS affiliate_log.api_requests CASCADE;

CREATE TABLE affiliate_log.api_requests (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    affiliate_id bigint,                                   -- Affiliate ID (auth başarılıysa)
    user_id bigint,                                        -- Kullanıcı ID (auth başarılıysa)
    request_id uuid NOT NULL,                              -- İstek correlation ID
    method varchar(10) NOT NULL,                           -- HTTP method: GET, POST, PUT, DELETE
    endpoint varchar(255) NOT NULL,                        -- API endpoint
    query_params jsonb,                                    -- Query parametreleri
    request_body jsonb,                                    -- İstek body (sanitized)
    response_status smallint NOT NULL,                     -- HTTP response status
    response_time_ms int,                                  -- Response süresi (ms)
    ip_address inet NOT NULL,                              -- IP adresi
    user_agent varchar(500),                               -- Tarayıcı bilgisi
    error_message text,                                    -- Hata mesajı (varsa)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- İstek zamanı
);

COMMENT ON TABLE affiliate_log.api_requests IS 'API request logs for affiliate panel - performance monitoring and error analysis';
