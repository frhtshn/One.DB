-- =============================================
-- Tablo: logs.error_logs
-- Açıklama: Uygulama hata kayıtları
-- Hata takibi ve debug işlemleri için kullanılır
-- =============================================

DROP TABLE IF EXISTS logs.error_logs CASCADE;

CREATE TABLE IF NOT EXISTS logs.error_logs (
    id BIGSERIAL PRIMARY KEY,                              -- Kayıt ID
    error_code VARCHAR(100) NOT NULL,                      -- Hata kodu
    error_message TEXT NOT NULL,                           -- Hata mesajı
    exception_type VARCHAR(500),                           -- İstisna (Exception) türü
    http_status_code INT,                                  -- HTTP durum kodu
    is_retryable BOOLEAN DEFAULT FALSE,                    -- Tekrar denenebilir hata mı?
    tenant_id BIGINT,                                      -- Tenant ID
    user_id VARCHAR(100),                                  -- Kullanıcı ID
    correlation_id VARCHAR(100),                           -- Korelasyon ID
    request_path VARCHAR(2000),                            -- İstek yapılan yol (Path)
    request_method VARCHAR(20),                            -- İstek yöntemi (GET, POST vs.)
    resource_type VARCHAR(200),                            -- İlgili kaynak türü
    resource_key VARCHAR(500),                             -- İlgili kaynak anahtarı
    error_metadata JSONB,                                  -- Hata ile ilgili ek veriler
    stack_trace TEXT,                                      -- Hata izi (Stack trace)
    cluster_name VARCHAR(100),                             -- Hatanın oluştuğu küme (Cluster) adı
    occurred_at TIMESTAMPTZ NOT NULL,                      -- Hatanın oluştuğu zaman
    created_at TIMESTAMPTZ DEFAULT NOW()                   -- Kaydın veritabanına yazıldığı zaman
);

COMMENT ON TABLE logs.error_logs IS 'Stores application errors for monitoring and debugging. Used by ErrorDataService, ErrorAuditGrain.';
