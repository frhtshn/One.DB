-- ================================================================
-- SOCIAL_LINK_LIST: Sosyal medya linklerini listele
-- is_contact filtresi ile sosyal profiller / iletişim kanalları ayrılır
-- ================================================================

DROP FUNCTION IF EXISTS presentation.list_social_links(BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.list_social_links(
    p_is_contact        BOOLEAN DEFAULT NULL,   -- NULL = tümü, TRUE = iletişim, FALSE = sosyal profil
    p_include_inactive  BOOLEAN DEFAULT FALSE
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
                platform,
                url,
                icon_class      AS "iconClass",
                display_order   AS "displayOrder",
                is_contact      AS "isContact",
                is_active       AS "isActive",
                created_at      AS "createdAt",
                updated_at      AS "updatedAt"
            FROM presentation.social_links
            WHERE (p_is_contact IS NULL OR is_contact = p_is_contact)
              AND (p_include_inactive OR is_active = TRUE)
            ORDER BY display_order, id
        ) t
    );
END;
$$;

COMMENT ON FUNCTION presentation.list_social_links(BOOLEAN, BOOLEAN) IS 'List social links. p_is_contact=NULL returns all, TRUE returns contact channels only, FALSE returns social profiles only.';
