-- =============================================
-- Tablo: billing.provider_settlement_clients
-- Açıklama: Settlement client bazında breakdown
-- Her settlement için client bazında detaylar
-- Reconciliation karşılaştırması için
-- =============================================

DROP TABLE IF EXISTS billing.provider_settlement_clients CASCADE;

CREATE TABLE billing.provider_settlement_clients (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    provider_settlement_id bigint NOT NULL,                -- Settlement ID (FK: billing.provider_settlements)
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)

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

    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı


);

COMMENT ON TABLE billing.provider_settlement_clients IS 'Per-client breakdown within provider settlements for detailed reconciliation and variance analysis';
