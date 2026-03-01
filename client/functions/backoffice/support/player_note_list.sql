-- ================================================================
-- PLAYER_NOTE_LIST: Oyuncu notlarını listele
-- ================================================================
-- Bir oyuncuya ait aktif notları sayfalı listeler.
-- Pinned notlar önce, sonra created_at DESC sıralama.
-- Opsiyonel note_type filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_note_list(BIGINT, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION support.player_note_list(
    p_player_id     BIGINT,
    p_note_type     VARCHAR(20) DEFAULT NULL,
    p_page          INT DEFAULT 1,
    p_page_size     INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM support.player_notes
    WHERE player_id = p_player_id
      AND is_active = true
      AND (p_note_type IS NULL OR note_type = p_note_type);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', pn.id,
            'playerId', pn.player_id,
            'noteType', pn.note_type,
            'content', pn.content,
            'isPinned', pn.is_pinned,
            'createdBy', pn.created_by,
            'createdAt', pn.created_at,
            'updatedAt', pn.updated_at
        ) AS item
        FROM support.player_notes pn
        WHERE pn.player_id = p_player_id
          AND pn.is_active = true
          AND (p_note_type IS NULL OR pn.note_type = p_note_type)
        ORDER BY pn.is_pinned DESC, pn.created_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', GREATEST(p_page, 1),
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION support.player_note_list IS 'Lists active player notes with optional type filter. Pinned notes appear first, then sorted by creation date descending.';
