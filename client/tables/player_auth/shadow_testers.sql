-- =============================================
-- Tablo: auth.shadow_testers
-- Açıklama: Shadow mode test oyuncuları
-- Shadow rollout statüsündeki provider oyunlarını
-- görebilen test oyuncuları listesi.
-- =============================================

DROP TABLE IF EXISTS auth.shadow_testers CASCADE;

CREATE TABLE auth.shadow_testers (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    player_id BIGINT NOT NULL UNIQUE,                               -- Oyuncu ID (auth.players FK — client DB içi)
    note VARCHAR(255),                                              -- Not: neden shadow tester yapıldı
    added_by VARCHAR(100),                                          -- Ekleyen kullanıcı bilgisi
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()                   -- Oluşturulma zamanı
);

COMMENT ON TABLE auth.shadow_testers IS 'Shadow mode test players who can see games in shadow rollout status. Used for staged provider rollouts.';
