-- =============================================
-- Tablo: affiliate.affiliate_users
-- Açıklama: Affiliate panel kullanıcıları
-- Affiliate'lerin sisteme giriş yapan kullanıcıları
-- Bir affiliate'in birden fazla kullanıcısı olabilir
-- Üst affiliate, alt affiliate için sınırlı kullanıcı ekleyebilir
-- =============================================

DROP TABLE IF EXISTS affiliate.affiliate_users CASCADE;

CREATE TABLE affiliate.affiliate_users (
    id bigserial PRIMARY KEY,                              -- Benzersiz kullanıcı kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (FK: affiliate.affiliates)
    email varchar(150) NOT NULL,                           -- E-posta adresi (giriş için)
    password varchar(255) NOT NULL,                        -- Hash'lenmiş şifre (bcrypt/argon2)
    first_name varchar(50),                                -- Kullanıcı adı
    last_name varchar(50),                                 -- Kullanıcı soyadı
    role varchar(30) NOT NULL DEFAULT 'VIEWER',            -- Rol: OWNER, ADMIN, MANAGER, VIEWER
    created_by_user_id bigint,                             -- Oluşturan kullanıcı (NULL = sistem/owner)
    created_by_affiliate_id bigint,                        -- Oluşturan affiliate (üst affiliate ise)
    can_manage_sub_affiliates boolean NOT NULL DEFAULT false, -- Alt affiliate yönetebilir mi?
    can_view_network_stats boolean NOT NULL DEFAULT false, -- Network istatistiklerini görebilir mi?
    can_create_users boolean NOT NULL DEFAULT false,       -- Kullanıcı oluşturabilir mi?
    max_users_allowed smallint DEFAULT 5,                  -- Oluşturabileceği max kullanıcı sayısı
    status smallint NOT NULL DEFAULT 1,                    -- Durum: 0=Pasif, 1=Aktif, 2=Askıda, 3=Kilitli
    failed_login_count smallint NOT NULL DEFAULT 0,        -- Başarısız giriş sayısı
    locked_until timestamp without time zone,              -- Kilit bitiş zamanı
    last_login_at timestamp without time zone,             -- Son başarılı giriş zamanı
    last_login_ip inet,                                    -- Son giriş IP adresi
    password_changed_at timestamp without time zone,       -- Son şifre değişiklik zamanı
    must_change_password boolean NOT NULL DEFAULT false,   -- İlk girişte şifre değiştirmeli mi?
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone                 -- Son güncelleme zamanı
);

COMMENT ON TABLE affiliate.affiliate_users IS 'Affiliate panel user accounts with role-based access control and sub-affiliate management capabilities';
COMMENT ON COLUMN affiliate.affiliate_users.role IS 'OWNER=full access, ADMIN=manage users, MANAGER=view reports, VIEWER=read-only';
COMMENT ON COLUMN affiliate.affiliate_users.created_by_affiliate_id IS 'Parent affiliate ID if user was created by upline affiliate';

-- =============================================
-- Rol Yetkileri:
--
-- OWNER: Tam yetki (affiliate sahibi)
--   - Tüm raporları görür
--   - Kullanıcı ekler/siler
--   - Alt affiliate yönetir
--   - Ödeme talep eder
--
-- ADMIN: Yönetici
--   - Tüm raporları görür
--   - VIEWER kullanıcı ekleyebilir
--   - Ödeme talep edemez
--
-- MANAGER: Raporlama yetkisi
--   - Tüm raporları görür
--   - Kullanıcı yönetemez
--
-- VIEWER: Salt okunur
--   - Sadece kendi kampanya raporları
-- =============================================

