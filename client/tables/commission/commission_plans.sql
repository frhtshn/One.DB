-- =============================================
-- Tablo: commission.commission_plans
-- Açıklama: Komisyon plan tanımları
-- Affiliate'lerin hangi oranlarla komisyon alacağını belirler
-- Sözleşme seviyesinde plan tanımları
-- =============================================

DROP TABLE IF EXISTS commission.commission_plans CASCADE;

CREATE TABLE commission.commission_plans (
    id bigserial PRIMARY KEY,                              -- Benzersiz plan kimliği
    code varchar(50) UNIQUE NOT NULL,                      -- Plan kodu (benzersiz tanımlayıcı)
    name varchar(100) NOT NULL,                            -- Plan adı (görüntüleme için)
    model varchar(20) NOT NULL,                            -- Komisyon modeli: REVSHARE, CPA, HYBRID

    -- Revenue Share Ayarları
    revshare_metric varchar(20) DEFAULT 'NGR',             -- Hangi metrik üzerinden: GGR, NGR
    revshare_enabled boolean NOT NULL DEFAULT true,        -- RevShare aktif mi?

    -- CPA Ayarları (Cost Per Acquisition)
    cpa_enabled boolean NOT NULL DEFAULT false,            -- CPA aktif mi?
    cpa_amount numeric(18,2) DEFAULT 0,                    -- FTD başına sabit tutar
    cpa_currency varchar(20),                               -- CPA para birimi (Fiat: TRY, Crypto: BTC)
    cpa_qualifying_deposit numeric(18,2),                  -- Minimum qualifying deposit

    -- Hybrid Ayarları
    hybrid_revshare_percent numeric(5,2),                  -- Hybrid modda RevShare yüzdesi (örn: 50 = yarısı)
    hybrid_cpa_percent numeric(5,2),                       -- Hybrid modda CPA yüzdesi (örn: 50 = yarısı)

    -- Genel Ayarlar
    base_currency varchar(20) NOT NULL,                     -- Baz para birimi (Fiat: TRY, Crypto: BTC)
    min_payout_amount numeric(18,2) DEFAULT 100,           -- Minimum ödeme tutarı
    payment_terms_days smallint DEFAULT 30,                -- Ödeme vadesi (gün)

    -- Durum
    is_active boolean NOT NULL DEFAULT true,               -- Plan aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE commission.commission_plans IS 'Affiliate commission plan definitions supporting revenue share (GGR/NGR), CPA, and hybrid models';
COMMENT ON COLUMN commission.commission_plans.revshare_metric IS 'Revenue share calculation base: GGR (Gross) or NGR (Net after deductions)';
COMMENT ON COLUMN commission.commission_plans.model IS 'REVSHARE=percentage of GGR/NGR, CPA=fixed per FTD, HYBRID=combination of both';

-- =============================================
-- Örnek Plan Konfigürasyonları:
--
-- 1. STANDART NGR REVSHARE:
--    model: REVSHARE
--    revshare_metric: NGR
--    revshare_enabled: true
--    → Tier'lara göre %25-%40 NGR
--
-- 2. GGR REVSHARE (Premium):
--    model: REVSHARE
--    revshare_metric: GGR
--    revshare_enabled: true
--    → Kesintisiz brüt gelir üzerinden
--
-- 3. SADE CPA:
--    model: CPA
--    cpa_enabled: true
--    cpa_amount: 50.00
--    cpa_qualifying_deposit: 100.00
--    → Her FTD için $50
--
-- 4. HYBRID (NGR + CPA):
--    model: HYBRID
--    revshare_metric: NGR
--    revshare_enabled: true
--    cpa_enabled: true
--    cpa_amount: 25.00
--    → %20 NGR + $25 CPA
--
-- 5. HYBRID (GGR + CPA):
--    model: HYBRID
--    revshare_metric: GGR
--    revshare_enabled: true
--    cpa_enabled: true
--    cpa_amount: 30.00
--    → %15 GGR + $30 CPA
-- =============================================
