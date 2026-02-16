-- Catalog Schema Indexes (Finance DB)
-- Core DB'den taşınan payment_methods indexleri + yeni tablo indexleri

-- =============================================
-- payment_providers indexes
-- =============================================

-- provider_code unique lookup (payment_provider_sync)
CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_providers_code ON catalog.payment_providers USING btree(provider_code);

-- is_active filtresi (aktif provider listesi)
CREATE INDEX IF NOT EXISTS idx_payment_providers_active ON catalog.payment_providers USING btree(is_active) WHERE is_active = true;

-- =============================================
-- payment_methods indexes (Core'dan taşındı + ek)
-- =============================================

-- provider_id FK index (JOIN performance)
CREATE INDEX IF NOT EXISTS idx_payment_methods_provider_id ON catalog.payment_methods USING btree(provider_id);

-- payment_type filtresi (cashier sorguları)
CREATE INDEX IF NOT EXISTS idx_payment_methods_payment_type ON catalog.payment_methods USING btree(payment_type);

-- is_active filtresi (aktif yöntem listesi)
CREATE INDEX IF NOT EXISTS idx_payment_methods_is_active ON catalog.payment_methods USING btree(is_active);

-- supports_deposit filtresi (para yatırma yöntemleri)
CREATE INDEX IF NOT EXISTS idx_payment_methods_deposit ON catalog.payment_methods USING btree(supports_deposit) WHERE supports_deposit = true;

-- supports_withdrawal filtresi (para çekme yöntemleri)
CREATE INDEX IF NOT EXISTS idx_payment_methods_withdrawal ON catalog.payment_methods USING btree(supports_withdrawal) WHERE supports_withdrawal = true;

-- supported_currencies GIN (array @> operatörü ile filtreleme)
CREATE INDEX IF NOT EXISTS idx_payment_methods_currencies ON catalog.payment_methods USING GIN(supported_currencies);

-- features GIN (array @> operatörü ile filtreleme)
CREATE INDEX IF NOT EXISTS idx_payment_methods_features ON catalog.payment_methods USING GIN(features);

-- popülerlik sıralaması (cashier varsayılan sıralama)
CREATE INDEX IF NOT EXISTS idx_payment_methods_popularity ON catalog.payment_methods USING btree(popularity_score DESC) WHERE is_active = true;

-- =============================================
-- payment_method_currency_limits indexes
-- =============================================

-- payment_method_id FK index (JOIN performance)
CREATE INDEX IF NOT EXISTS idx_pm_currency_limits_method ON catalog.payment_method_currency_limits USING btree(payment_method_id);

-- currency_type filtresi (fiat vs crypto ayırma)
CREATE INDEX IF NOT EXISTS idx_pm_currency_limits_currency_type ON catalog.payment_method_currency_limits USING btree(currency_type);

-- aktif limitler (soft delete filtresi)
CREATE INDEX IF NOT EXISTS idx_pm_currency_limits_active ON catalog.payment_method_currency_limits USING btree(payment_method_id) WHERE is_active = true;
