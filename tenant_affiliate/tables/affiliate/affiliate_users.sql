DROP TABLE IF EXISTS affiliate.affiliate_users CASCADE;

-- Affiliate kullanıcıları (Affiliate Panel Login)
-- Affiliate'lerin sisteme giriş yapan kullanıcıları
CREATE TABLE affiliate.affiliate_users (
    id bigserial PRIMARY KEY,
    affiliate_id bigint NOT NULL,           -- Affiliate referansı
    email varchar(150) NOT NULL,            -- E-posta adresi
    password varchar(255) NOT NULL,         -- Şifre hash'i
    status smallint NOT NULL,               -- ACTIVE / SUSPENDED
    last_login_at timestamp without time zone,  -- Son giriş zamanı
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
