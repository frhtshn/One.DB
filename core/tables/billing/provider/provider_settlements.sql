-- =============================================
-- Tablo: billing.provider_settlements
-- Açıklama: Provider settlement/reconciliation kayıtları
-- Dönemsel mutabakat ve hesap özeti
-- Provider'dan gelen statement ile karşılaştırma
-- =============================================

DROP TABLE IF EXISTS billing.provider_settlements CASCADE;

CREATE TABLE billing.provider_settlements (
    id bigserial PRIMARY KEY,                              -- Benzersiz settlement kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)

    -- Dönem bilgileri
    period_type varchar(10) NOT NULL,                      -- Dönem tipi: MONTHLY, WEEKLY
    period_key varchar(20) NOT NULL,                       -- Dönem anahtarı: 2026-01, 2026-W04
    period_start date NOT NULL,                            -- Dönem başlangıcı
    period_end date NOT NULL,                              -- Dönem bitişi

    -- Bizim hesapladığımız toplamlar
    our_total_bet numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam bahis
    our_total_win numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam kazanç
    our_total_ggr numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam GGR
    our_total_ngr numeric(18,6) NOT NULL DEFAULT 0,        -- Bizim toplam NGR
    our_commission_amount numeric(18,6) NOT NULL DEFAULT 0, -- Bizim hesapladığımız komisyon

    -- Provider'ın bildirdiği toplamlar
    provider_total_bet numeric(18,6),                      -- Provider toplam bahis
    provider_total_win numeric(18,6),                      -- Provider toplam kazanç
    provider_total_ggr numeric(18,6),                      -- Provider toplam GGR
    provider_total_ngr numeric(18,6),                      -- Provider toplam NGR
    provider_commission_amount numeric(18,6),              -- Provider hesapladığı komisyon

    -- Fark analizi
    bet_difference numeric(18,6),                          -- Bahis farkı
    win_difference numeric(18,6),                          -- Kazanç farkı
    ggr_difference numeric(18,6),                          -- GGR farkı
    commission_difference numeric(18,6),                   -- Komisyon farkı

    -- Para birimi
    currency character(3) NOT NULL,                        -- Para birimi

    -- Kabul edilen tutar
    agreed_amount numeric(18,6),                           -- Mutabık kalınan tutar
    adjustment_amount numeric(18,6) DEFAULT 0,             -- Düzeltme tutarı

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Taslak, 1=Hesaplandı, 2=Provider Bekleniyor, 3=Mutabık, 4=İhtilaf, 5=Kapatıldı

    -- Provider statement
    provider_statement_ref varchar(100),                   -- Provider statement referansı
    provider_statement_date date,                          -- Provider statement tarihi
    provider_statement_url text,                           -- Statement dosya URL

    -- İhtilaf bilgileri
    dispute_reason text,                                   -- İhtilaf sebebi
    dispute_resolved_at timestamp without time zone,       -- İhtilaf çözüm zamanı

    -- Notlar
    notes text,                                            -- Notlar

    -- Onay bilgileri
    reconciled_by bigint,                                  -- Mutabakat yapan kullanıcı ID
    reconciled_at timestamp without time zone,             -- Mutabakat zamanı

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now() -- Son güncelleme zamanı


);

COMMENT ON TABLE billing.provider_settlements IS 'Provider settlement and reconciliation records comparing internal calculations with provider statements for dispute resolution';
