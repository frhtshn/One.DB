-- =============================================
-- Tablo: commission.commissions
-- Açıklama: Hesaplanan affiliate komisyonları
-- Dönemsel olarak hesaplanan komisyon kayıtları
-- Network dağılımında her seviyeye ayrı kayıt oluşturulur
-- GGR, NGR ve CPA bazlı karma modelleri destekler
-- Audit ve ödeme takibi için kullanılır
-- =============================================

DROP TABLE IF EXISTS commission.commissions CASCADE;

CREATE TABLE commission.commissions (
    id bigserial PRIMARY KEY,                              -- Benzersiz komisyon kimliği
    affiliate_id bigint NOT NULL,                          -- Komisyon sahibi affiliate ID
    commission_plan_id bigint NOT NULL,                    -- Komisyon planı ID
    source_affiliate_id bigint,                            -- Network ise kaynak alt affiliate ID (oyuncuyu getiren)
    player_affiliate_id bigint,                            -- Oyuncuyu doğrudan getiren affiliate ID

    -- Komisyon Tipi
    commission_type varchar(20) NOT NULL,                  -- Komisyon tipi: DIRECT, NETWORK_L1, NETWORK_L2, NETWORK_L3
    commission_model varchar(20) NOT NULL,                 -- Model: REVSHARE, CPA, HYBRID
    network_level smallint DEFAULT 0,                      -- Network seviyesi (0=direkt, 1=bir üst, 2=iki üst...)

    -- RevShare Hesaplaması (GGR/NGR bazlı)
    revshare_metric varchar(10),                           -- Kullanılan metrik: GGR veya NGR
    revshare_base_amount numeric(18,2) DEFAULT 0,          -- Baz tutar (GGR veya NGR)
    revshare_base_rate numeric(5,2) DEFAULT 0,             -- Baz komisyon oranı (tier'dan)
    revshare_applied_rate numeric(5,2) DEFAULT 0,          -- Uygulanan oran (network split sonrası)
    revshare_amount numeric(18,2) DEFAULT 0,               -- RevShare komisyon tutarı

    -- CPA Hesaplaması (FTD bazlı)
    cpa_ftd_count int DEFAULT 0,                           -- FTD sayısı
    cpa_rate_per_ftd numeric(18,2) DEFAULT 0,              -- FTD başına tutar
    cpa_amount numeric(18,2) DEFAULT 0,                    -- CPA komisyon tutarı

    -- Toplam
    amount numeric(18,2) NOT NULL,                         -- Toplam komisyon (revshare + cpa)

    -- Dönem
    period_start date NOT NULL,                            -- Dönem başlangıç tarihi
    period_end date NOT NULL,                              -- Dönem bitiş tarihi
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    -- Negatif Bakiye Mahsubu
    carryforward_deduction numeric(18,2) DEFAULT 0,        -- Önceki dönemden mahsup edilen
    net_amount numeric(18,2) NOT NULL,                     -- Net komisyon (amount - carryforward)

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- Durum: 0=Hesaplandı, 1=Onaylandı, 2=Ödendi, 3=İptal
    batch_id uuid,                                         -- Hesaplama batch ID (aynı dönem aynı batch)
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone
);

COMMENT ON TABLE commission.commissions IS 'Calculated affiliate commissions supporting GGR/NGR RevShare, CPA, and Hybrid models with network distribution';
COMMENT ON COLUMN commission.commissions.revshare_metric IS 'GGR for gross gaming revenue, NGR for net after deductions';
COMMENT ON COLUMN commission.commissions.net_amount IS 'Final payable amount after carryforward deductions';

-- =============================================
-- Örnek Komisyon Kayıtları:
--
-- 1. SADE NGR REVSHARE:
-- | commission_model | revshare_metric | revshare_base | rate | revshare_amount | cpa_amount | amount |
-- |------------------|-----------------|---------------|------|-----------------|------------|--------|
-- | REVSHARE         | NGR             | $10,000       | 30%  | $3,000          | $0         | $3,000 |
--
-- 2. SADE GGR REVSHARE:
-- | commission_model | revshare_metric | revshare_base | rate | revshare_amount | cpa_amount | amount |
-- |------------------|-----------------|---------------|------|-----------------|------------|--------|
-- | REVSHARE         | GGR             | $12,000       | 25%  | $3,000          | $0         | $3,000 |
--
-- 3. SADE CPA:
-- | commission_model | ftd_count | cpa_rate | revshare_amount | cpa_amount | amount |
-- |------------------|-----------|----------|-----------------|------------|--------|
-- | CPA              | 15        | $50      | $0              | $750       | $750   |
--
-- 4. HYBRID (NGR + CPA):
-- | commission_model | revshare_metric | revshare_base | rate | ftd_count | cpa_rate | revshare | cpa  | amount |
-- |------------------|-----------------|---------------|------|-----------|----------|----------|------|--------|
-- | HYBRID           | NGR             | $10,000       | 20%  | 10        | $25      | $2,000   | $250 | $2,250 |
--
-- 5. HYBRID (GGR + CPA):
-- | commission_model | revshare_metric | revshare_base | rate | ftd_count | cpa_rate | revshare | cpa  | amount |
-- |------------------|-----------------|---------------|------|-----------|----------|----------|------|--------|
-- | HYBRID           | GGR             | $15,000       | 15%  | 10        | $30      | $2,250   | $300 | $2,550 |
-- =============================================
