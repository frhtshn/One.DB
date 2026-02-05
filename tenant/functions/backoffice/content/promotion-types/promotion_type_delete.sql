-- ================================================================
-- PROMOTION_TYPE_DELETE: Promosyon türü sil (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Kullanımda olan tür silinemez
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_type_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.promotion_types WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion-type.not-found';
    END IF;

    -- Kullanım kontrolü
    IF EXISTS(SELECT 1 FROM content.promotions WHERE promotion_type_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promotion-type.in-use';
    END IF;

    -- İlişkili translations sil
    DELETE FROM content.promotion_type_translations WHERE promotion_type_id = p_id;

    -- Türü sil
    DELETE FROM content.promotion_types WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_delete IS 'Deletes a promotion type. Cannot delete if in use. Auth check done in Core DB.';
