-- =============================================
-- Tablo: security.users
-- Açıklama: Backoffice kullanıcı tablosu
-- Sisteme giriş yapan tüm yönetici kullanıcılar
-- Kullanıcılar şirkete bağlıdır, rolleri tenant bazındadır
-- =============================================

DROP TABLE IF EXISTS security.users CASCADE;

CREATE TABLE security.users (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz kullanıcı kimliği
    company_id BIGINT NOT NULL,                            -- Bağlı şirket ID (FK: core.companies)
    first_name VARCHAR(50) NOT NULL,                       -- Kullanıcı adı
    last_name VARCHAR(50) NOT NULL,                        -- Kullanıcı soyadı
    email VARCHAR(255) NOT NULL,                           -- E-posta adresi
    username VARCHAR(50) NOT NULL,                         -- Kullanıcı adı (giriş için)
    password VARCHAR(255) NOT NULL,                        -- Hash'lenmiş şifre
    status SMALLINT NOT NULL DEFAULT 1,                    -- Durum: 0=Pasif, 1=Aktif, 2=Askıda
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,              -- Hesap kilitli mi?
    locked_until TIMESTAMPTZ,                              -- Kilitlenme bitiş zamanı
    failed_login_count INT NOT NULL DEFAULT 0,             -- Başarısız giriş denemesi sayısı
    last_login_at TIMESTAMPTZ,                             -- Son başarılı giriş zamanı
    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,     -- 2FA aktif mi?
    two_factor_secret VARCHAR(255),                        -- 2FA gizli anahtarı
    language CHAR(2),                                      -- Tercih edilen dil
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Kayıt oluşturma zamanı
    created_by BIGINT,                                     -- Oluşturan kullanıcı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Son güncelleme zamanı
    updated_by BIGINT,                                     -- Güncelleyen kullanıcı

    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_company_username UNIQUE (company_id, username)
);

COMMENT ON TABLE security.users IS 'BackOffice administrator user accounts with authentication credentials, 2FA settings, and company association';
