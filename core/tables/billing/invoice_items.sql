-- =============================================
-- Tablo: billing.invoice_items
-- Açıklama: Fatura kalem detayları
-- Her fatura satırının detay bilgileri
-- Komisyon kayıtlarıyla ilişkilendirilir
-- =============================================

DROP TABLE IF EXISTS billing.invoice_items CASCADE;

CREATE TABLE billing.invoice_items (
    id bigserial PRIMARY KEY,                              -- Benzersiz kalem kimliği
    invoice_id bigint NOT NULL,                            -- Fatura ID (FK: billing.invoices)
    tenant_commission_id bigint,                           -- Komisyon kaydı ID (FK: billing.tenant_commissions)

    -- Kalem bilgileri
    item_type varchar(30) NOT NULL,                        -- Kalem tipi: COMMISSION, ADJUSTMENT, DISCOUNT
    product_code varchar(30) NOT NULL,                     -- Ürün kodu: GAME, SPORTS, PAYMENT
    description varchar(255) NOT NULL,                     -- Kalem açıklaması

    -- Dönem bilgileri (komisyon için)
    period_start date,                                     -- Dönem başlangıcı
    period_end date,                                       -- Dönem bitişi

    -- Tutar bilgileri
    quantity numeric(18,6) NOT NULL DEFAULT 1,             -- Miktar
    unit_price numeric(18,6) NOT NULL,                     -- Birim fiyat
    subtotal numeric(18,6) NOT NULL,                       -- Ara toplam (quantity * unit_price)
    tax_rate numeric(5,2) NOT NULL DEFAULT 0,              -- KDV oranı (%)
    tax_amount numeric(18,6) NOT NULL DEFAULT 0,           -- KDV tutarı
    total_amount numeric(18,6) NOT NULL,                   -- Toplam tutar
    currency character(3) NOT NULL,                        -- Para birimi

    -- Hesaplama detayları (komisyon için)
    base_amount numeric(18,6),                             -- Baz tutar (GGR/NGR)
    commission_rate numeric(5,2),                          -- Komisyon oranı (%)
    commission_type varchar(20),                           -- Komisyon tipi: GGR, NGR, TURNOVER

    -- Sıralama
    sort_order smallint NOT NULL DEFAULT 0,                -- Görüntüleme sırası

    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);
