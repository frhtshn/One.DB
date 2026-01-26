-- =============================================
-- Tablo: billing.invoice_payments
-- Açıklama: Fatura ödeme kayıtları
-- Faturalara yapılan ödemelerin takibi
-- Kısmi ödemeler için birden fazla kayıt olabilir
-- =============================================

DROP TABLE IF EXISTS billing.invoice_payments CASCADE;

CREATE TABLE billing.invoice_payments (
    id bigserial PRIMARY KEY,                              -- Benzersiz ödeme kimliği
    invoice_id bigint NOT NULL,                            -- Fatura ID (FK: billing.invoices)

    -- Ödeme bilgileri
    payment_date date NOT NULL,                            -- Ödeme tarihi
    amount numeric(18,6) NOT NULL,                         -- Ödeme tutarı
    currency character(3) NOT NULL,                        -- Para birimi

    -- Ödeme detayları
    payment_method varchar(30) NOT NULL,                   -- Ödeme yöntemi: BANK_TRANSFER, NETTING, CREDIT
    payment_reference varchar(100),                        -- Ödeme referans numarası
    bank_reference varchar(100),                           -- Banka dekont numarası

    -- Netting (mahsuplaşma) bilgileri
    is_netting boolean NOT NULL DEFAULT false,             -- Mahsuplaşma mı?
    netting_invoice_id bigint,                             -- Mahsup edilen fatura ID

    -- Notlar
    notes text,                                            -- Ödeme notları

    recorded_by bigint,                                    -- Kaydeden kullanıcı ID (FK: security.users)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
