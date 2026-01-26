-- =============================================
-- Tablo: billing.provider_settlement_tenants
-- Açıklama: Settlement tenant bazında breakdown
-- Her settlement için tenant bazında detaylar
-- Reconciliation karşılaştırması için
-- =============================================

DROP TABLE IF EXISTS billing.provider_settlement_tenants CASCADE;

CREATE TABLE billing.provider_settlement_tenants (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    provider_settlement_id bigint NOT NULL,                -- Settlement ID (FK: billing.provider_settlements)
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)

    -- Bizim hesapladığımız
    our_total_bet numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam bahis
    our_total_win numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam kazanç
    our_total_ggr numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam GGR
    our_total_ngr numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam NGR
    our_commission_amount numeric(18,6) NOT NULL DEFAULT 0, -- Bizim hesapladığımız komisyon

    -- Provider'ın bildirdiği (varsa)
    provider_total_ggr numeric(18,6),                      -- Provider toplam GGR
    provider_commission_amount numeric(18,6),              -- Provider hesapladığı komisyon

    -- Fark
    ggr_difference numeric(18,6),                          -- GGR farkı
    commission_difference numeric(18,6),                   -- Komisyon farkı

    -- Para birimi
    currency character(3) NOT NULL,                        -- Para birimi

    -- Doğrulama
    verified boolean NOT NULL DEFAULT false,               -- Doğrulandı mı?

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı

    -- Settlement + Tenant benzersiz
    UNIQUE (provider_settlement_id, tenant_id)
);
