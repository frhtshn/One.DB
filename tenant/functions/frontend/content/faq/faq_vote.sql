-- ================================================================
-- FAQ_VOTE: SSS faydalılık oyu ver (Frontend)
-- ================================================================
-- Public action - yetki kontrolü gerekmez.
-- helpful_count veya not_helpful_count artırır.
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_vote(INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION content.faq_vote(
    p_faq_item_id INTEGER,
    p_is_helpful BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.faq_items WHERE id = p_faq_item_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-item.not-found';
    END IF;

    -- Oy güncelle
    IF p_is_helpful THEN
        UPDATE content.faq_items
        SET helpful_count = helpful_count + 1
        WHERE id = p_faq_item_id;
    ELSE
        UPDATE content.faq_items
        SET not_helpful_count = not_helpful_count + 1
        WHERE id = p_faq_item_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION content.faq_vote IS
'Records a helpfulness vote for a FAQ item.
No auth required (public action).
Usage: SELECT content.faq_vote(123, TRUE) -- helpful
       SELECT content.faq_vote(123, FALSE) -- not helpful';
