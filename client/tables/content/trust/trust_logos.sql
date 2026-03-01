-- =============================================
-- Tablo: content.trust_logos
-- Açıklama: Güven & uyumluluk logoları
-- Footer'da görünen lisans rozetleri (lisans HARIÇ),
-- sorumlu oyun logoları, ödeme ikonları ve güvenlik sertifikaları
-- =============================================

DROP TABLE IF EXISTS content.trust_logos CASCADE;

CREATE TABLE content.trust_logos (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    logo_type      VARCHAR(50)  NOT NULL,                          -- rg_org, testing_cert, payment, ssl_badge, award, partner_logo
    code           VARCHAR(100) NOT NULL UNIQUE,                   -- Benzersiz tanımlayıcı (örn. ecogra_cert, visa_payment)
    name           VARCHAR(200) NOT NULL,                          -- Görünen ad
    logo_url       VARCHAR(500) NOT NULL,                          -- Logo görsel URL'si
    link_url       VARCHAR(500),                                    -- Tıklanabilir hedef URL
    display_order  SMALLINT     NOT NULL DEFAULT 0,                -- Sıralama
    country_codes  VARCHAR(2)[] NOT NULL DEFAULT '{}',             -- Boş dizi = tüm ülkeler
    is_active      BOOLEAN      NOT NULL DEFAULT TRUE,             -- Aktif/pasif
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by     BIGINT,
    updated_by     BIGINT
);

COMMENT ON TABLE content.trust_logos IS 'Trust and compliance logos for site footer: responsible gaming organizations, testing certificates, payment icons, SSL badges, awards. Does NOT include license badges (see operator_licenses).';
