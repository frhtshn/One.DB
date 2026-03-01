-- =============================================
-- Tablo: content.operator_licenses
-- Açıklama: Operatör oyun lisansları
-- Footer lisans rozeti için tek kaynak
-- jurisdiction_id: core.catalog.jurisdictions.id (cross-DB, backend doğrular)
-- =============================================

DROP TABLE IF EXISTS content.operator_licenses CASCADE;

CREATE TABLE content.operator_licenses (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jurisdiction_id  INT          NOT NULL,                        -- core DB: catalog.jurisdictions.id (cross-DB FK yok, backend doğrular)
    license_number   VARCHAR(200) NOT NULL,                        -- Resmi lisans numarası
    verification_url VARCHAR(500),                                  -- Operatöre özel doğrulama linki (regülatör sitesi)
    logo_url         VARCHAR(500),                                  -- Operatöre özel logo URL'si (katalogdan farklılaştırılabilir)
    country_codes    VARCHAR(2)[] NOT NULL DEFAULT '{}',           -- Boş dizi = tüm ülkelere göster
    issued_date      DATE,                                          -- Lisans verilme tarihi
    expiry_date      DATE,                                          -- Lisans son geçerlilik tarihi
    display_order    SMALLINT     NOT NULL DEFAULT 0,              -- Sıralama
    is_active        BOOLEAN      NOT NULL DEFAULT TRUE,           -- Aktif/pasif
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by       BIGINT,
    updated_by       BIGINT,

    CONSTRAINT uq_operator_license UNIQUE (jurisdiction_id, license_number)
);

COMMENT ON TABLE content.operator_licenses IS 'Operator gaming licenses. Single source for footer license badges. jurisdiction_id references core.catalog.jurisdictions (validated by backend). Regulator name, country, and website_url fetched via cross-DB lookup.';
