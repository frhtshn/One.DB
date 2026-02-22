-- ================================================================
-- TRUST_LOGO_UPSERT: Güven logosu ekle / güncelle
-- code alanı üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS content.upsert_trust_logo(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, SMALLINT, VARCHAR[], INTEGER);

CREATE OR REPLACE FUNCTION content.upsert_trust_logo(
    p_code          VARCHAR(100),
    p_logo_type     VARCHAR(50),
    p_name          VARCHAR(200),
    p_logo_url      VARCHAR(500),
    p_link_url      VARCHAR(500)    DEFAULT NULL,
    p_display_order SMALLINT        DEFAULT 0,
    p_country_codes VARCHAR(2)[]    DEFAULT '{}',
    p_user_id       INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_code IS NULL OR TRIM(p_code) = '' THEN
        RAISE EXCEPTION 'error.trust-logo.code-required';
    END IF;
    IF p_logo_type IS NULL OR TRIM(p_logo_type) = '' THEN
        RAISE EXCEPTION 'error.trust-logo.type-required';
    END IF;
    IF p_name IS NULL OR TRIM(p_name) = '' THEN
        RAISE EXCEPTION 'error.trust-logo.name-required';
    END IF;
    IF p_logo_url IS NULL OR TRIM(p_logo_url) = '' THEN
        RAISE EXCEPTION 'error.trust-logo.logo-url-required';
    END IF;

    INSERT INTO content.trust_logos (
        code, logo_type, name, logo_url, link_url,
        display_order, country_codes, created_by, updated_by
    )
    VALUES (
        TRIM(p_code), p_logo_type, p_name, p_logo_url, p_link_url,
        COALESCE(p_display_order, 0), COALESCE(p_country_codes, '{}'), p_user_id, p_user_id
    )
    ON CONFLICT (code) DO UPDATE SET
        logo_type     = EXCLUDED.logo_type,
        name          = EXCLUDED.name,
        logo_url      = EXCLUDED.logo_url,
        link_url      = EXCLUDED.link_url,
        display_order = EXCLUDED.display_order,
        country_codes = EXCLUDED.country_codes,
        updated_by    = EXCLUDED.updated_by,
        updated_at    = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.upsert_trust_logo(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, SMALLINT, VARCHAR[], INTEGER) IS 'Insert or update a trust logo by code. Returns the logo ID.';
