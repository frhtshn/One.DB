-- =============================================
-- Popup Schedules (Popup Zamanlaması)
-- Gün ve saat bazlı gösterim kuralları
-- =============================================

DROP TABLE IF EXISTS content.popup_schedules CASCADE;

CREATE TABLE content.popup_schedules (
    id SERIAL PRIMARY KEY,
    popup_id INTEGER NOT NULL,                    -- Bağlı popup

    -- Gün Seçimi
    day_sunday BOOLEAN NOT NULL DEFAULT TRUE,
    day_monday BOOLEAN NOT NULL DEFAULT TRUE,
    day_tuesday BOOLEAN NOT NULL DEFAULT TRUE,
    day_wednesday BOOLEAN NOT NULL DEFAULT TRUE,
    day_thursday BOOLEAN NOT NULL DEFAULT TRUE,
    day_friday BOOLEAN NOT NULL DEFAULT TRUE,
    day_saturday BOOLEAN NOT NULL DEFAULT TRUE,

    -- Saat Aralığı
    start_time TIME WITHOUT TIME ZONE,            -- Başlangıç saati
    end_time TIME WITHOUT TIME ZONE,              -- Bitiş saati

    -- Timezone
    timezone VARCHAR(50) DEFAULT 'UTC',

    -- Öncelik
    priority INTEGER NOT NULL DEFAULT 0,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.popup_schedules IS 'Day and time-based scheduling rules for popups';
