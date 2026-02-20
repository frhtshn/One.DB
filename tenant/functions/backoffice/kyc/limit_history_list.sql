-- ================================================================
-- LIMIT_HISTORY_LIST: Limit/kısıtlama geçmişi
-- ================================================================
-- Oyuncunun limit ve kısıtlama değişiklik geçmişi.
-- Sayfalı, filtrelenebilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.limit_history_list(BIGINT, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION kyc.limit_history_list(
    p_player_id   BIGINT,
    p_entity_type VARCHAR(30) DEFAULT NULL,
    p_page        INT DEFAULT 1,
    p_page_size   INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INT;
    v_total  BIGINT;
    v_items  JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-limit.player-required';
    END IF;

    v_offset := (p_page - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*)
    INTO v_total
    FROM kyc.player_limit_history h
    WHERE h.player_id = p_player_id
      AND (p_entity_type IS NULL OR h.entity_type = p_entity_type);

    -- Sayfalı liste
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', h.id,
            'actionType', h.action_type,
            'entityType', h.entity_type,
            'entityId', h.entity_id,
            'oldValue', h.old_value,
            'newValue', h.new_value,
            'performedBy', h.performed_by,
            'adminUserId', h.admin_user_id,
            'reason', h.reason,
            'createdAt', h.created_at
        ) ORDER BY h.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM kyc.player_limit_history h
    WHERE h.player_id = p_player_id
      AND (p_entity_type IS NULL OR h.entity_type = p_entity_type)
    ORDER BY h.created_at DESC
    LIMIT p_page_size OFFSET v_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc.limit_history_list IS 'Paginated limit/restriction change history for a player. Optional entity_type filter (limit/restriction).';
