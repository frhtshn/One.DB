-- =============================================
-- Tablo: commission.network_commission_distributions
-- Açıklama: Çok katmanlı network komisyon dağılımları
-- Oyuncu getiren affiliate'den itibaren tüm üst zincire dağılım
-- Toplam hiçbir zaman base rate'i geçmez
-- =============================================

DROP TABLE IF EXISTS commission.network_commission_distributions CASCADE;

CREATE TABLE commission.network_commission_distributions (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    commission_plan_id bigint NOT NULL,                    -- Plan ID (FK: commission.commission_plans)
    level_from_player smallint NOT NULL,                   -- Oyuncuya uzaklık (0=direkt getiren, 1=bir üst, 2=iki üst...)
    rate_percent numeric(5,2) NOT NULL,                    -- Bu seviyenin alacağı base rate yüzdesi
    max_levels smallint NOT NULL DEFAULT 3,                -- Maksimum kaç seviyeye dağılım yapılacak
    is_active boolean NOT NULL DEFAULT true,               -- Kural aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone,                -- Son güncelleme zamanı
    CONSTRAINT chk_valid_level CHECK (level_from_player >= 0),
    CONSTRAINT chk_valid_rate CHECK (rate_percent >= 0 AND rate_percent <= 100)
);

COMMENT ON TABLE commission.network_commission_distributions IS 'Multi-level network commission distribution defining percentage allocation per level from player-acquiring affiliate upward';

-- =============================================
-- Örnek Senaryo (4 seviyeli network):
--
-- Player → Affiliate D → Affiliate C → Affiliate B → Affiliate A
--          (level 0)      (level 1)      (level 2)      (level 3)
--
-- Base Commission Rate: %30 (NGR bazlı)
--
-- | Level | Rate % | Gerçek Oran | Açıklama            |
-- |-------|--------|-------------|---------------------|
-- |   0   |   60   |   %18.0     | D - Oyuncuyu getiren|
-- |   1   |   20   |   %6.0      | C - Bir üst         |
-- |   2   |   12   |   %3.6      | B - İki üst         |
-- |   3   |   8    |   %2.4      | A - Üç üst          |
-- |-------|--------|-------------|---------------------|
-- | TOPLAM|  100   |   %30.0     | Base rate'i geçmedi!|
--
-- Her affiliate'e AYRI ödeme çıkar:
-- - Affiliate D: $180 (1000$ NGR üzerinden)
-- - Affiliate C: $60
-- - Affiliate B: $36
-- - Affiliate A: $24
-- =============================================
