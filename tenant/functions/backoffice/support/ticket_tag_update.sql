-- ================================================================
-- TICKET_TAG_UPDATE: Ticket etiketi güncelle
-- ================================================================
-- Mevcut etiketin adını ve/veya rengini günceller.
-- Sadece verilen parametreler güncellenir (COALESCE).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_tag_update(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_tag_update(
    p_tag_id    BIGINT,
    p_name      VARCHAR(50) DEFAULT NULL,
    p_color     VARCHAR(7) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_tag   RECORD;
BEGIN
    -- Etiket mevcut mu kontrol
    SELECT id, name INTO v_tag
    FROM support.ticket_tags
    WHERE id = p_tag_id AND is_active = true;

    IF v_tag.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.tag-not-found';
    END IF;

    -- En az bir alan değişmeli
    IF p_name IS NULL AND p_color IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.no-fields-to-update';
    END IF;

    -- Ad benzersizliği (değiştiriliyorsa)
    IF p_name IS NOT NULL AND TRIM(p_name) != '' THEN
        IF EXISTS (SELECT 1 FROM support.ticket_tags WHERE name = TRIM(p_name) AND is_active = true AND id != p_tag_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.tag-name-exists';
        END IF;
    END IF;

    -- Renk validasyonu (değiştiriliyorsa)
    IF p_color IS NOT NULL AND p_color !~ '^#[0-9A-Fa-f]{6}$' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-tag-color';
    END IF;

    -- Güncelle
    UPDATE support.ticket_tags
    SET name = COALESCE(NULLIF(TRIM(p_name), ''), name),
        color = COALESCE(p_color, color)
    WHERE id = p_tag_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_tag_update IS 'Updates ticket tag name and/or color. Only provided fields are changed.';
