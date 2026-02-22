-- ================================================================
-- SOCIAL_LINK_UPSERT: Sosyal medya linki ekle / güncelle
-- platform alanı üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS presentation.upsert_social_link(VARCHAR, VARCHAR, VARCHAR, SMALLINT, BOOLEAN, INTEGER);

CREATE OR REPLACE FUNCTION presentation.upsert_social_link(
    p_platform      VARCHAR(50),
    p_url           VARCHAR(500),
    p_icon_class    VARCHAR(100)    DEFAULT NULL,
    p_display_order SMALLINT        DEFAULT 0,
    p_is_contact    BOOLEAN         DEFAULT FALSE,
    p_user_id       INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_platform IS NULL OR TRIM(p_platform) = '' THEN
        RAISE EXCEPTION 'error.social-link.platform-required';
    END IF;
    IF p_url IS NULL OR TRIM(p_url) = '' THEN
        RAISE EXCEPTION 'error.social-link.url-required';
    END IF;

    INSERT INTO presentation.social_links (
        platform, url, icon_class, display_order, is_contact, created_by, updated_by
    )
    VALUES (
        LOWER(TRIM(p_platform)), p_url, p_icon_class,
        COALESCE(p_display_order, 0), COALESCE(p_is_contact, FALSE),
        p_user_id, p_user_id
    )
    ON CONFLICT (platform) DO UPDATE SET
        url           = EXCLUDED.url,
        icon_class    = EXCLUDED.icon_class,
        display_order = EXCLUDED.display_order,
        is_contact    = EXCLUDED.is_contact,
        is_active     = TRUE,
        updated_by    = EXCLUDED.updated_by,
        updated_at    = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION presentation.upsert_social_link(VARCHAR, VARCHAR, VARCHAR, SMALLINT, BOOLEAN, INTEGER) IS 'Insert or update a social link by platform. Platform is normalized to lowercase. Reactivates previously deleted entry on conflict. Returns the link ID.';
