-- ================================================================
-- LAYOUT_UPSERT: Sayfa yerleşimi oluştur/güncelle
-- JSONB structure ile widget pozisyonları tanımlanır
-- layout_name + page_id kombinasyonu mantıksal unique
-- ================================================================

DROP FUNCTION IF EXISTS presentation.layout_upsert(BIGINT, VARCHAR, BIGINT, JSONB);

CREATE OR REPLACE FUNCTION presentation.layout_upsert(
    p_id                BIGINT          DEFAULT NULL,   -- NULL = create, değer = update
    p_layout_name       VARCHAR(50)     DEFAULT 'default', -- Layout adı: home, game_detail, dashboard, default
    p_page_id           BIGINT          DEFAULT NULL,   -- Spesifik sayfa ID (NULL = global)
    p_structure         JSONB           DEFAULT '[]'    -- Widget yerleşim yapısı
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    -- Parametre doğrulama
    IF p_layout_name IS NULL OR p_layout_name = '' THEN
        RAISE EXCEPTION 'error.layout.name-required';
    END IF;

    IF p_structure IS NULL THEN
        RAISE EXCEPTION 'error.layout.structure-required';
    END IF;

    IF p_id IS NOT NULL THEN
        -- Update
        UPDATE presentation.layouts
        SET layout_name = COALESCE(p_layout_name, layout_name),
            page_id     = p_page_id,
            structure   = p_structure,
            updated_at  = NOW()
        WHERE id = p_id
        RETURNING id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'error.layout.not-found';
        END IF;
    ELSE
        -- Create
        INSERT INTO presentation.layouts (layout_name, page_id, structure)
        VALUES (p_layout_name, p_page_id, p_structure)
        RETURNING id INTO v_id;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.layout_upsert(BIGINT, VARCHAR, BIGINT, JSONB) IS 'Create or update page layout with JSONB widget structure. Pass NULL id to create, existing id to update.';
