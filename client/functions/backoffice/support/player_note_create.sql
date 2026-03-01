-- ================================================================
-- PLAYER_NOTE_CREATE: Oyuncu notu oluştur
-- ================================================================
-- BO kullanıcısı oyuncu profiline CRM tarzı not ekler.
-- Ticket'tan bağımsız kalıcı notlar: general, warning, vip, compliance.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_note_create(BIGINT, VARCHAR, TEXT, BOOLEAN, BIGINT);

CREATE OR REPLACE FUNCTION support.player_note_create(
    p_player_id     BIGINT,
    p_note_type     VARCHAR(20) DEFAULT 'general',
    p_content       TEXT DEFAULT NULL,
    p_is_pinned     BOOLEAN DEFAULT false,
    p_created_by    BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_note_id   BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.player-required';
    END IF;

    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.note-content-required';
    END IF;

    IF p_created_by IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.created-by-required';
    END IF;

    -- note_type validasyonu
    IF p_note_type NOT IN ('general', 'warning', 'vip', 'compliance') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-note-type';
    END IF;

    -- Not oluştur
    INSERT INTO support.player_notes (
        player_id, note_type, content, is_pinned,
        created_by, is_active, created_at, updated_at
    ) VALUES (
        p_player_id, p_note_type, p_content, p_is_pinned,
        p_created_by, true, NOW(), NOW()
    )
    RETURNING id INTO v_note_id;

    RETURN v_note_id;
END;
$$;

COMMENT ON FUNCTION support.player_note_create IS 'Creates a CRM-style player note. Supports types: general, warning, vip, compliance. Independent of tickets.';
