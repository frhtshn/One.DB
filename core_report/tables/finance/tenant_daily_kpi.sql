-- =============================================
-- Tablo: finance.tenant_daily_kpi
-- Açıklama: Tenant bazlı günlük özet KPI tablosu.
-- Yönetim panelinde "Hangi Tenant ne kadar ciro yapıyor?" sorusunu cevaplar.
-- =============================================

DROP TABLE IF EXISTS finance.tenant_daily_kpi CASCADE;

CREATE TABLE finance.tenant_daily_kpi (
    id bigserial PRIMARY KEY,                              -- Benzersiz ID
    report_date date NOT NULL,                             -- Rapor tarihi
    company_id bigint NOT NULL,                            -- Company ID (Hızlı filtreleme için)
    tenant_id bigint NOT NULL,                             -- Tenant ID
    currency char(3) NOT NULL,                             -- Para birimi

    -- Oyun Performansı
    total_bet numeric(18, 8) DEFAULT 0,
    total_win numeric(18, 8) DEFAULT 0,
    total_ggr numeric(18, 8) GENERATED ALWAYS AS (total_bet - total_win) STORED, -- Gross Gaming Revenue

    -- Finansal Hareketler
    total_deposits numeric(18, 8) DEFAULT 0,
    total_withdrawals numeric(18, 8) DEFAULT 0,
    total_bonuses numeric(18, 8) DEFAULT 0,
    net_cash_flow numeric(18, 8) GENERATED ALWAYS AS (total_deposits - total_withdrawals) STORED,

    -- Oyuncu Metrikleri
    active_player_count int DEFAULT 0,                     -- Günlük aktif oyuncu
    new_register_count int DEFAULT 0,                      -- Yeni kayıt
    ftd_count int DEFAULT 0,                               -- First Time Depositor

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE finance.tenant_daily_kpi IS 'Daily aggregated KPIs per tenant for central management reporting';
