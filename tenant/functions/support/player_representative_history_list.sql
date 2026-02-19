-- ================================================================
-- PLAYER_REPRESENTATIVE_HISTORY_LIST: Temsilci değişiklik tarihçesi
-- ================================================================
-- Bir oyuncunun temsilci atama/değişiklik geçmişini listeler.
-- En yeni kayıtlar önce (changed_at DESC).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_representative_history_list(BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION support.player_representative_history_list(
    p_player_id     BIGINT,
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
    FROM support.player_representative_history
    WHERE player_id = p_player_id;

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', h.id,
            'oldRepresentativeId', h.old_representative_id,
            'newRepresentativeId', h.new_representative_id,
            'changedBy', h.changed_by,
            'changeReason', h.change_reason,
            'changedAt', h.changed_at
        ) AS item
        FROM support.player_representative_history h
        WHERE h.player_id = p_player_id
        ORDER BY h.changed_at DESC
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

COMMENT ON FUNCTION support.player_representative_history_list IS 'Lists representative assignment history for a player. Most recent changes first.';
