-- =============================================
-- Tablo: auth.shadow_testers
-- Açıklama: Shadow mode test oyuncuları
-- Provider shadow mode'da açıldığında sadece bu
-- tablodaki oyuncular yeni entegrasyonu görebilir.
-- Tipik boyut: 5-10 kayıt per tenant.
-- UNIQUE(player_id) otomatik index oluşturur.
-- =============================================

DROP TABLE IF EXISTS auth.shadow_testers CASCADE;

CREATE TABLE auth.shadow_testers (
    id BIGSERIAL PRIMARY KEY,                                       -- Benzersiz kayıt kimliği
    player_id BIGINT NOT NULL,                                      -- Oyuncu ID (FK: auth.players)
    note VARCHAR(255),                                              -- Not: neden eklendi, hangi test
    added_by VARCHAR(100),                                          -- Ekleyen kullanıcı bilgisi
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                  -- Oluşturulma zamanı
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()                   -- Güncellenme zamanı
);

COMMENT ON TABLE auth.shadow_testers IS 'Shadow mode test players. Only these players can see provider integrations in shadow rollout status. Typically 5-10 records per tenant.';
