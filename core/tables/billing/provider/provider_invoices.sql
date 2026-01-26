-- =============================================
-- Tablo: billing.provider_invoices
-- Açıklama: Provider'lardan gelen faturalar
-- Oyun, ödeme vb. provider'ların Nucleo'ya kestiği faturalar
-- Settlement/reconciliation sonucu oluşan borçlar
-- =============================================

DROP TABLE IF EXISTS billing.provider_invoices CASCADE;

CREATE TABLE billing.provider_invoices (
    id bigserial PRIMARY KEY,                              -- Benzersiz fatura kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)

    -- Fatura bilgileri
    invoice_number varchar(100) NOT NULL,                  -- Provider fatura numarası
    invoice_type varchar(20) NOT NULL DEFAULT 'STANDARD',  -- Fatura tipi: STANDARD, CREDIT_NOTE, PROFORMA
    invoice_date date NOT NULL,                            -- Fatura tarihi
    due_date date NOT NULL,                                -- Ödeme vadesi
    received_date date,                                    -- Fatura alınma tarihi

    -- Dönem bilgileri
    period_start date NOT NULL,                            -- Dönem başlangıcı
    period_end date NOT NULL,                              -- Dönem bitişi

    -- Tutar bilgileri
    subtotal numeric(18,6) NOT NULL,                       -- Ara toplam (KDV hariç)
    tax_rate numeric(5,2) NOT NULL DEFAULT 0,              -- KDV/VAT oranı (%)
    tax_amount numeric(18,6) NOT NULL DEFAULT 0,           -- KDV/VAT tutarı
    total_amount numeric(18,6) NOT NULL,                   -- Toplam tutar (KDV dahil)
    currency character(3) NOT NULL,                        -- Para birimi: EUR, USD

    -- EUR cinsinden (raporlama için)
    total_amount_eur numeric(18,6),                        -- EUR karşılığı
    eur_rate numeric(18,8),                                -- Kullanılan EUR kuru

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Alındı, 1=Onaylandı, 2=Kısmi Ödeme, 3=Ödendi, 4=İhtilaf, 5=İptal

    -- Ödeme bilgileri
    paid_amount numeric(18,6) NOT NULL DEFAULT 0,          -- Ödenen tutar
    remaining_amount numeric(18,6) NOT NULL,               -- Kalan tutar
    last_payment_at timestamp without time zone,           -- Son ödeme zamanı

    -- Reconciliation bilgileri
    settlement_id bigint,                                  -- Settlement kaydı ID (varsa)
    reconciled boolean NOT NULL DEFAULT false,             -- Mutabakat yapıldı mı?
    reconciled_at timestamp without time zone,             -- Mutabakat zamanı

    -- Fark/düzeltme bilgileri
    adjustment_amount numeric(18,6) DEFAULT 0,             -- Düzeltme tutarı (+/-)
    adjustment_reason varchar(255),                        -- Düzeltme sebebi

    -- Doküman bilgileri
    document_url text,                                     -- Fatura dosyası URL
    document_hash varchar(64),                             -- Dosya hash (doğrulama için)

    -- Notlar
    notes text,                                            -- Fatura notları
    internal_notes text,                                   -- Dahili notlar

    -- Onay bilgileri
    approved_by bigint,                                    -- Onaylayan kullanıcı ID
    approved_at timestamp without time zone,               -- Onay zamanı

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now(), -- Son güncelleme zamanı

    -- Provider + invoice_number benzersiz
    UNIQUE (provider_id, invoice_number)
);

COMMENT ON TABLE billing.provider_invoices IS 'Invoices received from providers for game, payment, and other services with payment tracking and reconciliation status';
