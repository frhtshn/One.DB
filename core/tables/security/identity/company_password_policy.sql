-- =============================================
-- Tablo: security.company_password_policy
-- Açıklama: Company bazlı şifre politikası
-- Her company kendi şifre kurallarını belirleyebilir
-- Şifre karmaşıklık kuralları (uppercase, digit vb.) uygulama katmanında
-- =============================================

DROP TABLE IF EXISTS security.company_password_policy CASCADE;

CREATE TABLE security.company_password_policy (
    company_id BIGINT PRIMARY KEY,                            -- Her company için bir satır
    expiry_days INT NOT NULL DEFAULT 30,                      -- Şifre geçerlilik süresi (gün), 0 = sınırsız
    history_count INT NOT NULL DEFAULT 3,                     -- Kontrol edilecek eski şifre sayısı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),            -- Oluşturulma zamanı
    created_by BIGINT,                                        -- Oluşturan kullanıcı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),            -- Son güncelleme zamanı
    updated_by BIGINT                                         -- Güncelleyen kullanıcı
);

COMMENT ON TABLE security.company_password_policy IS 'Company-level password policy for BackOffice users';
