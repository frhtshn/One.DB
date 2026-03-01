-- =============================================
-- Tablo: commission.network_commission_splits
-- Açıklama: Network komisyon paylaşım kuralları
-- Alt ve üst affiliate arasındaki komisyon dağılımı
-- Toplam oran base rate'i geçmez (paralel ödeme modeli)
-- =============================================

DROP TABLE IF EXISTS commission.network_commission_splits CASCADE;

CREATE TABLE commission.network_commission_splits (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    commission_plan_id bigint NOT NULL,                    -- Plan ID (FK: commission.commission_plans)
    network_level smallint NOT NULL,                       -- Network seviyesi (1=direkt üst, 2=iki kademe üst...)
    child_rate_percent numeric(5,2) NOT NULL,              -- Alt affiliate'in alacağı oran yüzdesi (örn: 75 = base'in %75'i)
    parent_rate_percent numeric(5,2) NOT NULL,             -- Üst affiliate'in alacağı oran yüzdesi (örn: 25 = base'in %25'i)
    max_total_percent numeric(5,2) NOT NULL DEFAULT 100,   -- Maksimum toplam oran (normalde 100%)
    is_active boolean NOT NULL DEFAULT true,               -- Kural aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone,                -- Son güncelleme zamanı
    CONSTRAINT chk_split_total CHECK (child_rate_percent + parent_rate_percent <= max_total_percent),
    CONSTRAINT chk_positive_rates CHECK (child_rate_percent >= 0 AND parent_rate_percent >= 0)
);

COMMENT ON TABLE commission.network_commission_splits IS 'Network commission split rules defining parallel payment distribution between parent and child affiliates without exceeding base rate';
COMMENT ON COLUMN commission.network_commission_splits.child_rate_percent IS 'Percentage of base commission rate allocated to the child (direct) affiliate';
COMMENT ON COLUMN commission.network_commission_splits.parent_rate_percent IS 'Percentage of base commission rate allocated to the parent (upline) affiliate';
COMMENT ON COLUMN commission.network_commission_splits.max_total_percent IS 'Maximum allowed total percentage (child + parent), typically 100%';

-- =============================================
-- Örnek Senaryo:
-- Base Commission Rate: %30 (NGR bazlı)
-- child_rate_percent: 75 → Alt affiliate %22.5 alır (30 * 0.75)
-- parent_rate_percent: 25 → Üst affiliate %7.5 alır (30 * 0.25)
-- Toplam: %30 (base rate'i geçmedi)
--
-- Her ikisine de AYRI ödeme çıkar!
-- =============================================
