-- ================================================================
-- PROMOTION_DELETE: Promosyon sil (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Hard delete - promotion tablosunda is_deleted yok
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.promotions WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion.not-found';
    END IF;

    -- İlişkili banners sil
    DELETE FROM content.promotion_banners WHERE promotion_id = p_id;

    -- İlişkili translations sil
    DELETE FROM content.promotion_translations WHERE promotion_id = p_id;

    -- İlişkili segments sil
    DELETE FROM content.promotion_segments WHERE promotion_id = p_id;

    -- İlişkili games sil
    DELETE FROM content.promotion_games WHERE promotion_id = p_id;

    -- İlişkili display locations sil
    DELETE FROM content.promotion_display_locations WHERE promotion_id = p_id;

    -- Promosyonu sil
    DELETE FROM content.promotions WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_delete IS 'Deletes a promotion and all related data. Auth check done in Core DB.';
