-- =============================================
-- Slide Schedules (Slide Zamanlaması)
-- Gün ve saat bazlı gösterim kuralları
-- Hafta içi/sonu, belirli saatler için özelleştirme
-- =============================================

DROP TABLE IF EXISTS content.slide_schedules CASCADE;

CREATE TABLE content.slide_schedules (
    id SERIAL PRIMARY KEY,
    slide_id INTEGER NOT NULL,                    -- Bağlı slide

    -- Gün Seçimi (bit mask veya ayrı kolonlar)
    -- 0=Pazar, 1=Pazartesi, ... 6=Cumartesi
    day_sunday BOOLEAN NOT NULL DEFAULT TRUE,
    day_monday BOOLEAN NOT NULL DEFAULT TRUE,
    day_tuesday BOOLEAN NOT NULL DEFAULT TRUE,
    day_wednesday BOOLEAN NOT NULL DEFAULT TRUE,
    day_thursday BOOLEAN NOT NULL DEFAULT TRUE,
    day_friday BOOLEAN NOT NULL DEFAULT TRUE,
    day_saturday BOOLEAN NOT NULL DEFAULT TRUE,

    -- Saat Aralığı
    start_time TIME WITHOUT TIME ZONE,            -- Gösterim başlangıç saati (NULL = 00:00)
    end_time TIME WITHOUT TIME ZONE,              -- Gösterim bitiş saati (NULL = 23:59)

    -- Timezone
    timezone VARCHAR(50) DEFAULT 'UTC',           -- Saat dilimi

    -- Öncelik (çakışma durumunda)
    priority INTEGER NOT NULL DEFAULT 0,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.slide_schedules IS 'Day and time-based scheduling rules for slides with timezone support';

-- Kullanım Örnekleri:
-- 1. Sadece hafta sonu göster: day_saturday=TRUE, day_sunday=TRUE, diğerleri FALSE
-- 2. Sadece akşam saatleri: start_time='18:00', end_time='23:59'
-- 3. Happy Hour: day_monday-friday=TRUE, start_time='17:00', end_time='19:00'
-- 4. Maç saati özel: Belirli gün + saat aralığı
