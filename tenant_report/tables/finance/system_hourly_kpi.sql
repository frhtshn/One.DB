-- =============================================
-- Tablo: finance.system_hourly_kpi
-- Açıklama: Sistem genelindeki KPI metriklerinin saatlik özeti.
-- Yönetim dashboard'ları ve finansal özetler için kullanılır.
-- Oyuncu bağımsızdır, sistemin genel sağlığını gösterir.
-- =============================================

DROP TABLE IF EXISTS finance.system_hourly_kpi CASCADE;

CREATE TABLE finance.system_hourly_kpi (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt ID
    period_hour timestamp with time zone NOT NULL,         -- İlgili saat
    currency char(3) NOT NULL,                             -- Para birimi

    -- Operasyonel Metrikler
    unique_active_players int DEFAULT 0,                   -- O saatteki tekil aktif oyuncu (UAP)
    new_registrations int DEFAULT 0,                       -- Yeni üye sayısı
    first_time_depositors int DEFAULT 0,                   -- İlk yatırım yapanlar (FTD)

    -- Oyun Gelirleri (GGR/NGR)
    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_ggr numeric(18, 8) GENERATED ALWAYS AS (total_bet - total_win) STORED, -- Gross Gaming Revenue
    margin_percentage numeric(5,2) DEFAULT 0,              -- House Edge (Kar marjı)

    -- Kasa Hareketleri
    total_deposits numeric(18, 8) DEFAULT 0,
    total_withdrawals numeric(18, 8) DEFAULT 0,
    total_bonuses numeric(18, 8) DEFAULT 0,

    -- Net Cash Position
    -- Kasa farkı: Giren Para - Çıkan Para (Oyun karlılığından bağımsız nakit akışı)
    net_cash_flow numeric(18, 8) GENERATED ALWAYS AS (total_deposits - total_withdrawals) STORED,

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone

);

COMMENT ON TABLE finance.system_hourly_kpi IS 'System-wide hourly Key Performance Indicators (Non-player specific)';
