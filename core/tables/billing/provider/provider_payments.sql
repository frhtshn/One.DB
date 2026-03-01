-- =============================================
-- Tablo: billing.provider_payments
-- Açıklama: Provider'lara yapılan ödemeler
-- Sortis One'dan provider'lara yapılan gerçek ödemeler
-- Kısmi ödemeler için birden fazla kayıt olabilir
-- =============================================

DROP TABLE IF EXISTS billing.provider_payments CASCADE;

CREATE TABLE billing.provider_payments (
    id bigserial PRIMARY KEY,                              -- Benzersiz ödeme kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    provider_invoice_id bigint,                            -- Fatura ID (FK: billing.provider_invoices)

    -- Ödeme bilgileri
    payment_date date NOT NULL,                            -- Ödeme tarihi
    value_date date,                                       -- Valör tarihi
    amount numeric(18,6) NOT NULL,                         -- Ödeme tutarı
    currency character(3) NOT NULL,                        -- Para birimi

    -- EUR cinsinden
    amount_eur numeric(18,6),                              -- EUR karşılığı
    eur_rate numeric(18,8),                                -- Kullanılan EUR kuru

    -- Ödeme detayları
    payment_method varchar(30) NOT NULL,                   -- Ödeme yöntemi: BANK_TRANSFER, NETTING, CRYPTO
    payment_reference varchar(100),                        -- Ödeme referans numarası
    bank_reference varchar(100),                           -- Banka dekont/swift numarası

    -- Banka bilgileri
    from_bank_account varchar(50),                         -- Gönderen hesap
    to_bank_account varchar(50),                           -- Alıcı hesap (provider)

    -- Netting (mahsuplaşma) bilgileri
    is_netting boolean NOT NULL DEFAULT false,             -- Mahsuplaşma mı?
    netting_details jsonb,                                 -- Mahsup detayları

    -- Durum
    status smallint NOT NULL DEFAULT 0,                    -- 0=Beklemede, 1=Gönderildi, 2=Tamamlandı, 3=Başarısız

    -- Onay bilgileri
    approved_by bigint,                                    -- Onaylayan kullanıcı ID
    approved_at timestamp without time zone,               -- Onay zamanı

    -- Notlar
    notes text,                                            -- Ödeme notları

    created_by bigint,                                     -- Oluşturan kullanıcı ID
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE billing.provider_payments IS 'Payments made to providers including bank transfers, netting, and crypto with approval workflow';
