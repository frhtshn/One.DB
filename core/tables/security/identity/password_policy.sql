-- =============================================
-- Tablo: security.password_policy
-- Açıklama: Platform geneli şifre politikası
-- Tek satırlık tablo, tüm backoffice kullanıcıları için geçerli
-- Şifre karmaşıklık kuralları (uppercase, digit vb.) uygulama katmanında
-- =============================================

DROP TABLE IF EXISTS security.password_policy CASCADE;

CREATE TABLE security.password_policy (
    id SMALLINT PRIMARY KEY DEFAULT 1,                     -- Tek satır (sabit 1)
    expiry_days INT NOT NULL DEFAULT 30,                   -- Şifre geçerlilik süresi (gün), 0 = sınırsız
    history_count INT NOT NULL DEFAULT 3,                  -- Kontrol edilecek eski şifre sayısı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Son güncelleme zamanı
    updated_by BIGINT                                      -- Güncelleyen kullanıcı
);

COMMENT ON TABLE security.password_policy IS 'Platform-wide password policy for BackOffice users (single row)';
