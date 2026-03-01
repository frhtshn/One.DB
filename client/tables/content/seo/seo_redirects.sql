-- =============================================
-- Tablo: content.seo_redirects
-- Açıklama: URL yönlendirme kuralları
-- Eski/değişen URL'lerin yönetimi, SEO geçişleri
-- Backend middleware katmanı bu tabloyu sorgular
-- =============================================

DROP TABLE IF EXISTS content.seo_redirects CASCADE;

CREATE TABLE content.seo_redirects (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_slug     VARCHAR(500) NOT NULL UNIQUE,                     -- Kaynak URL yolu (/eski-promosyon)
    to_url        VARCHAR(500) NOT NULL,                            -- Hedef URL (/yeni-promosyon veya tam URL)
    redirect_type SMALLINT     NOT NULL DEFAULT 301,               -- 301 (kalıcı) veya 302 (geçici)
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    BIGINT,
    updated_by    BIGINT,

    CONSTRAINT chk_redirect_type CHECK (redirect_type IN (301, 302))
);

COMMENT ON TABLE content.seo_redirects IS 'URL redirect rules for SEO migrations and page restructuring. Backend middleware queries from_slug on every request. redirect_type must be 301 (permanent) or 302 (temporary).';
