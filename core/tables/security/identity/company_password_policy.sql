-- =============================================
-- Tablo: security.company_password_policy
-- Açıklama: Company bazlı şifre politikası
-- Her company kendi şifre kurallarını belirleyebilir
-- Karmaşıklık kuralları ve hesap kilitleme ayarları dahil
-- =============================================

DROP TABLE IF EXISTS security.company_password_policy CASCADE;

CREATE TABLE security.company_password_policy (
    company_id             BIGINT   PRIMARY KEY,               -- Her company için bir satır
    expiry_days            INT      NOT NULL DEFAULT 30,        -- Şifre geçerlilik süresi (gün), 0 = sınırsız
    history_count          INT      NOT NULL DEFAULT 3,         -- Kontrol edilecek eski şifre sayısı
    min_length             SMALLINT NOT NULL DEFAULT 8,         -- Minimum şifre uzunluğu
    require_uppercase      BOOLEAN  NOT NULL DEFAULT TRUE,      -- En az bir büyük harf zorunlu mu?
    require_lowercase      BOOLEAN  NOT NULL DEFAULT TRUE,      -- En az bir küçük harf zorunlu mu?
    require_digit          BOOLEAN  NOT NULL DEFAULT TRUE,      -- En az bir rakam zorunlu mu?
    require_special        BOOLEAN  NOT NULL DEFAULT FALSE,     -- En az bir özel karakter zorunlu mu?
    max_login_attempts     SMALLINT NOT NULL DEFAULT 5,         -- Kilitleme öncesi maks. başarısız giriş (0 = kilitleme yok)
    lockout_duration_minutes SMALLINT NOT NULL DEFAULT 30,      -- Hesap kilitleme süresi (dakika), 0 = manuel açma
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Oluşturulma zamanı
    created_by             BIGINT,                              -- Oluşturan kullanıcı
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- Son güncelleme zamanı
    updated_by             BIGINT                               -- Güncelleyen kullanıcı
);

COMMENT ON TABLE security.company_password_policy IS 'Company-level password policy for BackOffice users. Includes complexity rules (length, case, digits, special chars) and account lockout settings.';
