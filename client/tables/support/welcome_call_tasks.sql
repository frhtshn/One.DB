-- =============================================
-- Tablo: support.welcome_call_tasks
-- Açıklama: Hoşgeldin araması görev tablosu.
--           Oyuncu kaydolduğunda otomatik oluşturulur.
--           Deneme yönetimi ile call center kuyruğu.
-- =============================================

DROP TABLE IF EXISTS support.welcome_call_tasks CASCADE;

CREATE TABLE support.welcome_call_tasks (
    id                      BIGSERIAL       PRIMARY KEY,
    player_id               BIGINT          NOT NULL,               -- Oyuncu ID

    -- Durum makinesi
    status                  VARCHAR(20)     NOT NULL DEFAULT 'pending', -- pending, assigned, in_progress, completed, rescheduled, failed, cancelled

    -- Atama bilgileri
    assigned_to_id          BIGINT,                                 -- Görevi alan call center personeli (BO user_id)
    assigned_at             TIMESTAMPTZ,                            -- Atama zamanı

    -- Arama bilgileri
    call_result             VARCHAR(20),                            -- answered, no_answer, busy, voicemail, wrong_number, declined
    call_notes              TEXT,                                   -- Arama notları
    call_duration_seconds   INT,                                    -- Görüşme süresi (saniye)

    -- Deneme yönetimi
    attempt_count           SMALLINT        NOT NULL DEFAULT 0,     -- Yapılan deneme sayısı
    max_attempts            SMALLINT        NOT NULL DEFAULT 3,     -- Maksimum deneme (aşılınca → failed)
    next_attempt_at         TIMESTAMPTZ,                            -- Sonraki deneme zamanı (rescheduled için)

    -- Tarihler
    completed_at            TIMESTAMPTZ,                            -- Tamamlanma zamanı
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(), -- Görev oluşturulma (= oyuncu kayıt) zamanı
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Aynı oyuncuya aynı anda birden fazla aktif görev olmaz
CREATE UNIQUE INDEX IF NOT EXISTS uq_welcome_call_tasks_active_player
    ON support.welcome_call_tasks (player_id)
    WHERE status NOT IN ('completed', 'failed', 'cancelled');

COMMENT ON TABLE support.welcome_call_tasks IS 'Welcome call tasks auto-created on player registration. Tracks call attempts, results, and assignment for call center queue management.';
