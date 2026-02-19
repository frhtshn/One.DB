-- ================================================================
-- PLAYER_NOTE_DELETE: Oyuncu notu sil (soft delete)
-- ================================================================
-- Notu soft delete ile pasif yapar (is_active = false).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_note_delete(BIGINT);

CREATE OR REPLACE FUNCTION support.player_note_delete(
    p_note_id   BIGINT
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
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.note-already-deleted';
    END IF;

    -- Soft delete
    UPDATE support.player_notes
    SET is_active = false, updated_at = NOW()
    WHERE id = p_note_id;
END;
$$;

COMMENT ON FUNCTION support.player_note_delete IS 'Soft deletes a player note by setting is_active = false.';
