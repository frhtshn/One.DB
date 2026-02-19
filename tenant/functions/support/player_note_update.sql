-- ================================================================
-- PLAYER_NOTE_UPDATE: Oyuncu notu güncelle
-- ================================================================
-- Mevcut bir oyuncu notunun içeriğini, tipini veya pin durumunu
-- günceller. NULL gelen alanlar değişmez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_note_update(BIGINT, TEXT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION support.player_note_update(
    p_note_id       BIGINT,
    p_content       TEXT DEFAULT NULL,
    p_note_type     VARCHAR(20) DEFAULT NULL,
    p_is_pinned     BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_note  RECORD;
BEGIN
    -- Not mevcut mu kontrol
    SELECT id, is_active INTO v_note
    FROM support.player_notes
    WHERE id = p_note_id;

    IF v_note.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.note-not-found';
    END IF;

    IF v_note.is_active = false THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.note-deleted';
    END IF;

    -- note_type validasyonu (değiştiriliyorsa)
    IF p_note_type IS NOT NULL AND p_note_type NOT IN ('general', 'warning', 'vip', 'compliance') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-note-type';
    END IF;

    -- En az bir alan değişmeli
    IF p_content IS NULL AND p_note_type IS NULL AND p_is_pinned IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.no-update-fields';
    END IF;

    -- Güncelle
    UPDATE support.player_notes
    SET content    = COALESCE(p_content, content),
        note_type  = COALESCE(p_note_type, note_type),
        is_pinned  = COALESCE(p_is_pinned, is_pinned),
        updated_at = NOW()
    WHERE id = p_note_id;
END;
$$;

COMMENT ON FUNCTION support.player_note_update IS 'Updates an existing player note. Only provided fields are changed (NULL = no change).';
