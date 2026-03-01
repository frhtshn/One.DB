-- =============================================
-- Tablo: core.client_provisioning_log
-- Açıklama: Provisioning adım takibi
-- Her provisioning denemesi bir run_id ile gruplandırılır.
-- Her step bir kayıt olarak tutulur. Retry ve hata takibi.
-- =============================================

DROP TABLE IF EXISTS core.client_provisioning_log CASCADE;

CREATE TABLE core.client_provisioning_log (
    id BIGSERIAL PRIMARY KEY,                                     -- Benzersiz kayıt kimliği
    client_id BIGINT NOT NULL,                                    -- Client ID (FK: core.clients)
    provision_run_id UUID NOT NULL,                                -- Aynı provisioning denemesinin ID'si
    step_name VARCHAR(50) NOT NULL,                                -- VALIDATE, DB_PROVISION, DB_CREATE, DB_MIGRATE, DB_SEED, ...
    step_order SMALLINT NOT NULL,                                  -- Adım sırası: 1, 2, 3, ...

    -- Durum
    status VARCHAR(20) NOT NULL DEFAULT 'pending',                 -- pending, running, completed, failed, skipped, rolled_back
    started_at TIMESTAMPTZ,                                        -- Adım başlangıç zamanı
    completed_at TIMESTAMPTZ,                                      -- Adım bitiş zamanı
    duration_ms INTEGER,                                           -- Süre (millisaniye)

    -- Hata Takibi
    error_message TEXT,                                            -- Hata mesajı
    error_detail TEXT,                                             -- Stack trace / detay
    retry_count SMALLINT DEFAULT 0,                                -- Retry sayısı
    max_retries SMALLINT DEFAULT 3,                                -- Max retry

    -- Step Çıktısı
    output JSONB DEFAULT '{}',                                     -- Step-specific çıktılar

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE core.client_provisioning_log IS 'Step-by-step provisioning tracking. Each run (UUID) contains 11 ordered steps from VALIDATE to ACTIVATE. Supports retry, error tracking, and step-specific output.';
