-- =============================================
-- Tablo: support.player_representatives
-- Açıklama: Oyuncu ↔ müşteri temsilcisi kalıcı
--           atama. Her oyuncunun tek bir atanmış
--           temsilcisi olur. Değişiklik tarihçesi
--           player_representative_history'de tutulur.
-- =============================================

DROP TABLE IF EXISTS support.player_representatives CASCADE;

CREATE TABLE support.player_representatives (
    id                  BIGSERIAL       PRIMARY KEY,
    player_id           BIGINT          NOT NULL,               -- Oyuncu ID (UNIQUE — tek temsilci garantisi)
    representative_id   BIGINT          NOT NULL,               -- Atanan temsilci (BO user_id — plain BIGINT)
    assigned_by         BIGINT          NOT NULL,               -- Atamayı yapan BO user_id
    note                VARCHAR(500),                           -- Atama notu (ör: "Hoşgeldin araması sonrası")
    assigned_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW(), -- Atama zamanı

    -- Her oyuncunun yalnızca bir aktif temsilcisi
    CONSTRAINT uq_player_representative UNIQUE (player_id)
);

COMMENT ON TABLE support.player_representatives IS 'Player-to-representative permanent assignment. Each player has exactly one assigned customer representative. Changes are tracked in player_representative_history.';
