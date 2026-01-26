-- =============================================
-- Tablo: core.companies
-- Açıklama: Şirket ana tablosu
-- Platformda kayıtlı tüm holding/şirket bilgilerini tutar
-- Her şirket altında birden fazla tenant olabilir
-- =============================================

DROP TABLE IF EXISTS core.companies CASCADE;

CREATE TABLE core.companies (
    id bigserial PRIMARY KEY,                              -- Benzersiz şirket kimliği
    company_code varchar(50) NOT NULL UNIQUE,              -- Şirket sistem kodu: ACME, GLOBEX
    company_name varchar(255) NOT NULL,                    -- Şirket yasal unvanı
    status smallint NOT NULL DEFAULT 1,                    -- Durum: 0=Pasif, 1=Aktif, 2=Askıda
    country_code character(2),                             -- Merkezin bulunduğu ülke (FK: catalog.countries)
    timezone varchar(50),                                  -- Varsayılan saat dilimi: Europe/Istanbul
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

ALTER SEQUENCE core.companies_id_seq MINVALUE 0 RESTART WITH 0;
