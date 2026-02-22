-- =============================================
-- Tablo: presentation.social_links
-- Açıklama: Sosyal medya profilleri ve iletişim kanalları
-- Footer, iletişim sayfası ve header bölgelerinde kullanılır
-- =============================================

DROP TABLE IF EXISTS presentation.social_links CASCADE;

CREATE TABLE presentation.social_links (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    platform      VARCHAR(50)  NOT NULL UNIQUE,                    -- facebook, instagram, twitter, youtube, tiktok, telegram, discord, whatsapp, email, phone, live_chat
    url           VARCHAR(500) NOT NULL,                            -- Platform linki veya mailto:, tel: URI
    icon_class    VARCHAR(100),                                     -- CSS ikon sınıfı (örn. fab fa-facebook)
    display_order SMALLINT     NOT NULL DEFAULT 0,                 -- Sıralama
    is_contact    BOOLEAN      NOT NULL DEFAULT FALSE,             -- FALSE = sosyal profil, TRUE = iletişim kanalı
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,              -- Soft delete / görünürlük
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    BIGINT,
    updated_by    BIGINT
);

COMMENT ON TABLE presentation.social_links IS 'Social media profiles and contact channels. UNIQUE per platform. is_contact flag differentiates social profiles (Facebook, Instagram) from contact channels (WhatsApp, live chat). Used in footer and contact page.';
