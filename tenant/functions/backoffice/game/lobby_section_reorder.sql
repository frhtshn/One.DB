-- ================================================================
-- LOBBY_SECTION_REORDER: Lobi bölümlerini yeniden sırala
-- p_items: [{id, displayOrder}] dizisi
-- ================================================================

DROP FUNCTION IF EXISTS game.reorder_lobby_sections(JSONB, INTEGER);

CREATE OR REPLACE FUNCTION game.reorder_lobby_sections(
    p_items     JSONB,
    p_user_id   INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_item JSONB;
BEGIN
    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'error.lobby-section.items-required';
    END IF;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        UPDATE game.lobby_sections
        SET
            display_order = (v_item ->> 'displayOrder')::SMALLINT,
            updated_by    = p_user_id,
            updated_at    = NOW()
        WHERE id = (v_item ->> 'id')::BIGINT;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION game.reorder_lobby_sections(JSONB, INTEGER) IS 'Bulk update display_order for lobby sections. Accepts array of {id, displayOrder}.';
