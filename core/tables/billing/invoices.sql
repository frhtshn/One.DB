-- =============================================
-- Tablo: billing.invoices
-- Açıklama: Provider fatura ana tablosu
-- Tenant'lara kesilen provider komisyon faturaları
-- Birden fazla komisyon kaydı tek faturada toplanabilir
-- =============================================

DROP TABLE IF EXISTS billing.invoices CASCADE;

CREATE TABLE billing.invoices (
    id bigserial PRIMARY KEY,                              -- Benzersiz fatura kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    provider_code varchar(50) NOT NULL,                    -- Provider kodu

    -- Fatura bilgileri
    invoice_number varchar(50) NOT NULL UNIQUE,            -- Benzersiz fatura numarası
    invoice_type varchar(20) NOT NULL DEFAULT 'STANDARD',  -- Fatura tipi: STANDARD, CREDIT_NOTE, PROFORMA
    invoice_date date NOT NULL,                            -- Fatura tarihi
    due_date date NOT NULL,                                -- Ödeme vadesi

    -- Dönem bilgileri
    period_start date NOT NULL,                            -- Dönem başlangıç tarihi
    period_end date NOT NULL,                              -- Dönem bitiş tarihi

    -- Tutar bilgileri
    subtotal numeric(18,6) NOT NULL,                       -- Ara toplam (KDV hariç)
    tax_rate numeric(5,2) NOT NULL DEFAULT 0,              -- KDV oranı (%)
    tax_amount numeric(18,6) NOT NULL DEFAULT 0,           -- KDV tutarı
    total_amount numeric(18,6) NOT NULL,                   -- Toplam tutar (KDV dahil)
    currency character(3) NOT NULL,                        -- Para birimi: TRY, EUR, USD

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Taslak, 1=Kesildi, 2=Gönderildi, 3=Kısmi Ödeme, 4=Ödendi, 5=İptal

    -- Ödeme bilgileri
    paid_amount numeric(18,6) NOT NULL DEFAULT 0,          -- Ödenen tutar
    remaining_amount numeric(18,6) NOT NULL,               -- Kalan tutar
    last_payment_at timestamp without time zone,           -- Son ödeme zamanı

    -- E-fatura bilgileri (opsiyonel)
    e_invoice_id varchar(100),                             -- E-fatura entegrasyon ID
    e_invoice_status varchar(30),                          -- E-fatura durumu

    -- Notlar
    notes text,                                            -- Fatura notları
    internal_notes text,                                   -- Dahili notlar (müşteriye gösterilmez)

    -- İptal bilgileri
    cancelled_at timestamp without time zone,              -- İptal zamanı
    cancelled_by bigint,                                   -- İptal eden kullanıcı ID
    cancellation_reason varchar(255),                      -- İptal sebebi
    credit_note_id bigint,                                 -- İade faturası ID (varsa)

    created_by bigint,                                     -- Oluşturan kullanıcı ID (FK: security.users)
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);
