-- ================================================================
-- CANNED_RESPONSE_UPDATE: Hazır yanıt güncelle
-- ================================================================
-- Mevcut bir hazır yanıtın başlığını, içeriğini veya
-- kategori bağlantısını günceller. NULL gelen alanlar değişmez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.canned_response_update(BIGINT, VARCHAR, TEXT, BIGINT);

CREATE OR REPLACE FUNCTION support.canned_response_update(
    p_response_id   BIGINT,
    p_title         VARCHAR(100) DEFAULT NULL,
    p_content       TEXT DEFAULT NULL,
    p_category_id   BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_response  RECORD;
BEGIN
    -- Kayıt mevcut mu kontrol
    SELECT id, is_active INTO v_response
    FROM support.canned_responses
    WHERE id = p_response_id;

    IF v_response.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.canned-response-not-found';
    END IF;

    IF v_response.is_active = false THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.canned-response-deleted';
    END IF;

    -- Boş title kontrolü
    IF p_title IS NOT NULL AND TRIM(p_title) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.canned-title-required';
    END IF;

    -- Boş content kontrolü
    IF p_content IS NOT NULL AND TRIM(p_content) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.canned-content-required';
    END IF;

    -- Kategori kontrolü (değiştiriliyorsa)
    IF p_category_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
        END IF;
    END IF;

    -- En az bir alan değişmeli
    IF p_title IS NULL AND p_content IS NULL AND p_category_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.no-update-fields';
    END IF;

    -- Güncelle
    UPDATE support.canned_responses
    SET title       = COALESCE(TRIM(p_title), title),
        content     = COALESCE(p_content, content),
        category_id = COALESCE(p_category_id, category_id),
        updated_at  = NOW()
    WHERE id = p_response_id;
END;
$$;

COMMENT ON FUNCTION support.canned_response_update IS 'Updates a canned response template. Only provided fields are changed (NULL = no change).';
