-- =============================================
-- Tablo: security.user_password_history
-- Açıklama: Backoffice kullanıcı şifre geçmişi
-- Son N şifre saklanır, eski şifrelerle aynı şifre kullanımı engellenir
-- =============================================

DROP TABLE IF EXISTS security.user_password_history CASCADE;

CREATE TABLE security.user_password_history (
    id BIGSERIAL PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    password_hash VARCHAR(255) NOT NULL,                   -- Eski şifre hash'i
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()          -- Değişiklik zamanı
);

COMMENT ON TABLE security.user_password_history IS 'BackOffice user password change history for preventing reuse of recent passwords';
