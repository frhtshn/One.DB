-- ================================================================
-- CANNED_RESPONSE_CREATE: Hazır yanıt oluştur
-- ================================================================
-- Temsilcilerin sık kullandığı hazır yanıt şablonu oluşturur.
-- Opsiyonel kategori bağlantısı ile bağlamsal öneriler sunulabilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.canned_response_create(VARCHAR, TEXT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION support.canned_response_create(
    p_title         VARCHAR(100),
    p_content       TEXT,
    p_category_id   BIGINT DEFAULT NULL,
    p_created_by    BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_response_id   BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_title IS NULL OR TRIM(p_title) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.canned-title-required';
    END IF;

    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.canned-content-required';
    END IF;

    -- Kategori kontrolü (varsa aktif mi?)
    IF p_category_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
        END IF;
    END IF;

    -- Oluştur
    INSERT INTO support.canned_responses (
        title, content, category_id, created_by,
        is_active, created_at, updated_at
    ) VALUES (
        TRIM(p_title), p_content, p_category_id, p_created_by,
        true, NOW(), NOW()
    )
    RETURNING id INTO v_response_id;

    RETURN v_response_id;
END;
$$;

COMMENT ON FUNCTION support.canned_response_create IS 'Creates a canned response template for support agents. Can optionally be linked to a ticket category.';
