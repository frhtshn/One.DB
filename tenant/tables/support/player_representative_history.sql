-- =============================================
-- Tablo: support.player_representative_history
-- Açıklama: Temsilci atama değişiklik tarihçesi.
--           Immutable — kim, neden, ne zaman
--           değiştirmiş. Prim hakediş raporları
--           için sorgulanabilir.
-- =============================================

DROP TABLE IF EXISTS support.player_representative_history CASCADE;

CREATE TABLE support.player_representative_history (
    id                      BIGSERIAL       PRIMARY KEY,
    player_id               BIGINT          NOT NULL,               -- Oyuncu ID
    old_representative_id   BIGINT,                                 -- Önceki temsilci (ilk atamada NULL)
    new_representative_id   BIGINT          NOT NULL,               -- Yeni temsilci
    changed_by              BIGINT          NOT NULL,               -- Değişikliği yapan BO user_id
    change_reason           VARCHAR(500)    NOT NULL,               -- Değişiklik nedeni (zorunlu)
    changed_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW()  -- Değişiklik zamanı
);

COMMENT ON TABLE support.player_representative_history IS 'Immutable audit trail for player representative assignment changes. Records who changed the representative, the reason, and when.';
