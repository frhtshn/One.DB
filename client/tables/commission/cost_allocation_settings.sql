-- =============================================
-- Tablo: commission.cost_allocation_settings
-- Açıklama: Maliyet yansıtma ayarları
-- Hangi maliyetlerin NGR'dan düşüleceğini belirler
-- Affiliate sözleşmesine göre farklı ayarlar olabilir
-- =============================================

DROP TABLE IF EXISTS commission.cost_allocation_settings CASCADE;

CREATE TABLE commission.cost_allocation_settings (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    commission_plan_id bigint NOT NULL,                    -- Plan ID (FK: commission.commission_plans)

    -- Bonus Maliyetleri
    deduct_bonus_cost boolean NOT NULL DEFAULT true,       -- Bonus maliyetini düş
    bonus_cost_percent numeric(5,2) DEFAULT 100,           -- Bonus maliyetinin yüzde kaçı düşülsün (0-100)

    -- Depozit Maliyetleri
    deduct_deposit_fee boolean NOT NULL DEFAULT true,      -- Depozit PSP fee'sini düş
    deposit_fee_percent numeric(5,2) DEFAULT 100,          -- Depozit fee'nin yüzde kaçı düşülsün
    deposit_fixed_cost numeric(18,2) DEFAULT 0,            -- Depozit başına sabit maliyet

    -- Çekim Maliyetleri
    deduct_withdrawal_fee boolean NOT NULL DEFAULT true,   -- Çekim fee'sini düş
    withdrawal_fee_percent numeric(5,2) DEFAULT 100,       -- Çekim fee'nin yüzde kaçı düşülsün
    withdrawal_fixed_cost numeric(18,2) DEFAULT 0,         -- Çekim başına sabit maliyet

    -- Admin/Operasyon Maliyetleri
    deduct_admin_cost boolean NOT NULL DEFAULT false,      -- Admin maliyetini düş
    admin_cost_percent_of_ggr numeric(5,2) DEFAULT 0,      -- GGR'ın yüzde kaçı admin maliyeti
    admin_fixed_monthly numeric(18,2) DEFAULT 0,           -- Aylık sabit admin maliyeti

    -- Vergi/Lisans Maliyetleri
    deduct_tax_cost boolean NOT NULL DEFAULT false,        -- Vergi maliyetini düş
    tax_percent_of_ggr numeric(5,2) DEFAULT 0,             -- GGR'ın yüzde kaçı vergi

    -- Negatif NGR Politikası
    allow_negative_ngr boolean NOT NULL DEFAULT true,      -- Negatif NGR'a izin ver
    carry_forward_negative boolean NOT NULL DEFAULT true,  -- Negatif NGR'ı sonraki aya taşı
    max_carry_forward_months smallint DEFAULT 3,           -- Maksimum kaç ay taşınabilir

    -- Meta
    is_active boolean NOT NULL DEFAULT true,               -- Ayar aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    CONSTRAINT uq_cost_allocation_plan UNIQUE (commission_plan_id)
);

COMMENT ON TABLE commission.cost_allocation_settings IS 'Cost allocation settings per commission plan - defines which costs are deducted from GGR to calculate NGR';
COMMENT ON COLUMN commission.cost_allocation_settings.carry_forward_negative IS 'If true, negative NGR is carried to next month, reducing future commissions';

-- =============================================
-- Örnek Senaryolar:
--
-- 1. STANDART PLAN:
--    - Bonus: %100 düşülür
--    - Deposit fee: %100 düşülür
--    - Withdrawal fee: %100 düşülür
--    - Admin: Düşülmez
--    - Negatif NGR: Sonraki aya taşınır
--
-- 2. PREMİUM PLAN:
--    - Bonus: %50 düşülür (yarısını şirket üstlenir)
--    - Deposit fee: Düşülmez (şirket üstlenir)
--    - Withdrawal fee: %50 düşülür
--    - Admin: Düşülmez
--    - Negatif NGR: Taşınmaz (her ay sıfırdan başlar)
--
-- 3. VIP PLAN:
--    - Bonus: Düşülmez (tam brüt GGR üzerinden)
--    - Deposit/Withdrawal: Düşülmez
--    - Admin: Düşülmez
--    - Negatif NGR: Taşınmaz
-- =============================================
