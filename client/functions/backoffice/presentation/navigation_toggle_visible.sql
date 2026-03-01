-- ================================================================
-- NAVIGATION_TOGGLE_VISIBLE: Menü öğesi görünürlük aç/kapat
-- is_visible değerini tersine çevirir
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_toggle_visible(BIGINT);

CREATE OR REPLACE FUNCTION presentation.navigation_toggle_visible(
    p_id                BIGINT              -- Öğe ID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_visible BOOLEAN;
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.navigation.id-required';
    END IF;

    -- Toggle ve yeni değeri döndür
    UPDATE presentation.navigation
    SET is_visible = NOT is_visible,
        updated_at = NOW()
    WHERE id = p_id
    RETURNING is_visible INTO v_new_visible;

    IF v_new_visible IS NULL THEN
        RAISE EXCEPTION 'error.navigation.item-not-found';
    END IF;

    RETURN v_new_visible;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_toggle_visible(BIGINT) IS 'Toggle navigation item visibility. Returns new is_visible state.';
