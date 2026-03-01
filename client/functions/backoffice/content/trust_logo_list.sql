-- ================================================================
-- TRUST_LOGO_LIST: Güven logolarını listele
-- Tür ve aktiflik filtresi
-- ================================================================

DROP FUNCTION IF EXISTS content.list_trust_logos(VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION content.list_trust_logos(
    p_logo_type         VARCHAR(50)     DEFAULT NULL,   -- NULL = tüm türler
    p_include_inactive  BOOLEAN         DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(row_to_json(t)::JSONB ORDER BY t.display_order, t.id), '[]'::JSONB)
        FROM (
            SELECT
                id,
                code,
                logo_type       AS "logoType",
                name,
                logo_url        AS "logoUrl",
                link_url        AS "linkUrl",
                display_order   AS "displayOrder",
                country_codes   AS "countryCodes",
                is_active       AS "isActive",
                created_at      AS "createdAt",
                updated_at      AS "updatedAt"
            FROM content.trust_logos
            WHERE (p_logo_type IS NULL OR logo_type = p_logo_type)
              AND (p_include_inactive OR is_active = TRUE)
            ORDER BY display_order, id
        ) t
    );
END;
$$;

COMMENT ON FUNCTION content.list_trust_logos(VARCHAR, BOOLEAN) IS 'List trust logos with optional type filter. Returns sorted JSONB array.';
