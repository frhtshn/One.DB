-- =============================================
-- Tablo: billing.provider_invoice_items
-- Açıklama: Provider fatura kalem detayları
-- Her fatura satırının detay bilgileri
-- Tenant bazında breakdown olabilir
-- =============================================

DROP TABLE IF EXISTS billing.provider_invoice_items CASCADE;

CREATE TABLE billing.provider_invoice_items (
    id bigserial PRIMARY KEY,                              -- Benzersiz kalem kimliği
    provider_invoice_id bigint NOT NULL,                   -- Provider fatura ID (FK: billing.provider_invoices)

    -- Tenant bilgisi (varsa)
    tenant_id bigint,                                      -- Tenant ID (FK: core.tenants) - NULL = genel

    -- Kalem bilgileri
    item_type varchar(30) NOT NULL,                        -- Kalem tipi: GGR_COMMISSION, LICENSE_FEE, SETUP_FEE, ADJUSTMENT
    product_code varchar(30),                              -- Ürün kodu: GAME, SPORTS
    description varchar(255) NOT NULL,                     -- Kalem açıklaması

    -- Dönem bilgileri
    period_start date,                                     -- Dönem başlangıcı
    period_end date,                                       -- Dönem bitişi

    -- Hesaplama detayları (GGR komisyonu için)
    base_amount numeric(18,6),                             -- Baz tutar (GGR/NGR)
    commission_rate numeric(5,2),                          -- Komisyon oranı (%)

    -- Tutar bilgileri
    quantity numeric(18,6) NOT NULL DEFAULT 1,             -- Miktar
    unit_price numeric(18,6) NOT NULL,                     -- Birim fiyat
    subtotal numeric(18,6) NOT NULL,                       -- Ara toplam
    tax_rate numeric(5,2) NOT NULL DEFAULT 0,              -- KDV oranı (%)
    tax_amount numeric(18,6) NOT NULL DEFAULT 0,           -- KDV tutarı
    total_amount numeric(18,6) NOT NULL,                   -- Toplam tutar
    currency character(3) NOT NULL,                        -- Para birimi

    -- Doğrulama
    verified boolean NOT NULL DEFAULT false,               -- Hesaplama doğrulandı mı?
    our_calculated_amount numeric(18,6),                   -- Bizim hesapladığımız tutar
    difference_amount numeric(18,6),                       -- Fark (varsa)

    -- Sıralama
    sort_order smallint NOT NULL DEFAULT 0,                -- Görüntüleme sırası

    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE billing.provider_invoice_items IS 'Provider invoice line item details with tenant breakdown for commission, license fees, and adjustments';
