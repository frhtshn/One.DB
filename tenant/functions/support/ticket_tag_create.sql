-- ================================================================
-- TICKET_TAG_CREATE: Ticket etiketi oluştur
-- ================================================================
-- Yeni bir ticket etiketi oluşturur.
-- Aktif etiketlerde benzersiz ad kontrolü.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_tag_create(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_tag_create(
    p_name  VARCHAR(50),
    p_color VARCHAR(7) DEFAULT '#6B7280'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_tag_id    BIGINT;
BEGIN
    -- Ad validasyonu
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.tag-name-required';
    END IF;

    -- Aktif etiketlerde benzersiz ad
    IF EXISTS (SELECT 1 FROM support.ticket_tags WHERE name = TRIM(p_name) AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.tag-name-exists';
    END IF;

    -- Renk validasyonu (HEX format)
    IF p_color IS NOT NULL AND p_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-tag-color';
    END IF;

    -- Etiket oluştur
    INSERT INTO support.ticket_tags (name, color, is_active, created_at)
    VALUES (TRIM(p_name), COALESCE(p_color, '#6B7280'), true, NOW())
    RETURNING id INTO v_tag_id;

    RETURN v_tag_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_tag_create IS 'Creates a ticket tag with unique name and optional HEX color code.';
