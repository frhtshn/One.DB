-- =============================================
-- Tablo: affiliate.affiliate_users
-- Açıklama: Affiliate panel kullanıcıları
-- Affiliate'lerin sisteme giriş yapan kullanıcıları
-- Bir affiliate'in birden fazla kullanıcısı olabilir
-- =============================================

DROP TABLE IF EXISTS affiliate.affiliate_users CASCADE;

CREATE TABLE affiliate.affiliate_users (
    id bigserial PRIMARY KEY,                              -- Benzersiz kullanıcı kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    email varchar(150) NOT NULL,                           -- E-posta adresi (giriş için)
    password varchar(255) NOT NULL,                        -- Hash'lenmiş şifre (bcrypt/argon2)
    status smallint NOT NULL,                              -- Durum: 0=Pasif, 1=Aktif, 2=Askıda
    last_login_at timestamp without time zone,             -- Son başarılı giriş zamanı
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE affiliate.affiliate_users IS 'Affiliate panel user accounts with authentication for affiliate dashboard access';
