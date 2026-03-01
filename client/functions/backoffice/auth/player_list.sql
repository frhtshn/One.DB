-- ================================================================
-- PLAYER_LIST: BO oyuncu listesi
-- ================================================================
-- Sayfalı, filtrelenebilir oyuncu listesi.
-- Hash alanları ile exact-match arama (backend hash'ler).
-- LEFT JOIN LATERAL ile kategori/grup bilgisi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS auth.player_list(SMALLINT, BOOLEAN, VARCHAR, BYTEA, BYTEA, BYTEA, BYTEA, BYTEA, BIGINT, BIGINT, CHAR, DATE, DATE, TIMESTAMPTZ, TIMESTAMPTZ, INT, INT);

CREATE OR REPLACE FUNCTION auth.player_list(
    p_status           SMALLINT DEFAULT NULL,
    p_email_verified   BOOLEAN DEFAULT NULL,
    p_search           VARCHAR(255) DEFAULT NULL,
    p_email_hash       BYTEA DEFAULT NULL,
    p_first_name_hash  BYTEA DEFAULT NULL,
    p_last_name_hash   BYTEA DEFAULT NULL,
    p_phone_hash       BYTEA DEFAULT NULL,
    p_identity_no_hash BYTEA DEFAULT NULL,
    p_category_id      BIGINT DEFAULT NULL,
    p_group_id         BIGINT DEFAULT NULL,
    p_country_code     CHAR(2) DEFAULT NULL,
    p_birth_date_from  DATE DEFAULT NULL,
    p_birth_date_to    DATE DEFAULT NULL,
    p_date_from        TIMESTAMPTZ DEFAULT NULL,
    p_date_to          TIMESTAMPTZ DEFAULT NULL,
    p_page             INT DEFAULT 1,
    p_page_size        INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset     INT;
    v_total      BIGINT;
    v_items      JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*)
    INTO v_total
    FROM auth.players p
    LEFT JOIN profile.player_profile pp ON pp.player_id = p.id
    LEFT JOIN profile.player_identity pi ON pi.player_id = p.id
    WHERE (p_status IS NULL OR p.status = p_status)
      AND (p_email_verified IS NULL OR p.email_verified = p_email_verified)
      AND (p_search IS NULL OR p.username ILIKE '%' || p_search || '%')
      AND (p_email_hash IS NULL OR p.email_hash = p_email_hash)
      AND (p_first_name_hash IS NULL OR pp.first_name_hash = p_first_name_hash)
      AND (p_last_name_hash IS NULL OR pp.last_name_hash = p_last_name_hash)
      AND (p_phone_hash IS NULL OR pp.phone_hash = p_phone_hash)
      AND (p_identity_no_hash IS NULL OR pi.identity_no_hash = p_identity_no_hash)
      AND (p_country_code IS NULL OR pp.country_code = p_country_code)
      AND (p_birth_date_from IS NULL OR pp.birth_date >= p_birth_date_from)
      AND (p_birth_date_to IS NULL OR pp.birth_date <= p_birth_date_to)
      AND (p_date_from IS NULL OR p.registered_at >= p_date_from)
      AND (p_date_to IS NULL OR p.registered_at <= p_date_to)
      AND (p_category_id IS NULL OR EXISTS (
          SELECT 1 FROM auth.player_classification pcl
          WHERE pcl.player_id = p.id AND pcl.player_category_id = p_category_id
      ))
      AND (p_group_id IS NULL OR EXISTS (
          SELECT 1 FROM auth.player_classification pcl
          WHERE pcl.player_id = p.id AND pcl.player_group_id = p_group_id
      ));

    -- Sayfalı liste
    SELECT COALESCE(jsonb_agg(row_data), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', p.id,
            'username', p.username,
            'status', p.status,
            'emailVerified', p.email_verified,
            'registeredAt', p.registered_at,
            'lastLoginAt', p.last_login_at,
            'countryCode', pp.country_code,
            'city', pp.city,
            'category', cat.cat_data,
            'groups', grp.groups
        ) AS row_data
        FROM auth.players p
        LEFT JOIN profile.player_profile pp ON pp.player_id = p.id
        LEFT JOIN profile.player_identity pi ON pi.player_id = p.id
        LEFT JOIN LATERAL (
            SELECT jsonb_build_object(
                'id', pc.id,
                'code', pc.category_code,
                'name', pc.category_name,
                'level', pc.level
            ) AS cat_data
            FROM auth.player_classification pcl
            JOIN auth.player_categories pc ON pc.id = pcl.player_category_id
            WHERE pcl.player_id = p.id
              AND pcl.player_category_id IS NOT NULL
              AND pcl.player_group_id IS NULL
            LIMIT 1
        ) cat ON true
        LEFT JOIN LATERAL (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'id', pg.id,
                    'code', pg.group_code,
                    'name', pg.group_name,
                    'level', pg.level
                ) ORDER BY pg.level ASC
            ), '[]'::jsonb) AS groups
            FROM auth.player_classification pcl
            JOIN auth.player_groups pg ON pg.id = pcl.player_group_id
            WHERE pcl.player_id = p.id
              AND pcl.player_group_id IS NOT NULL
        ) grp ON true
        WHERE (p_status IS NULL OR p.status = p_status)
          AND (p_email_verified IS NULL OR p.email_verified = p_email_verified)
          AND (p_search IS NULL OR p.username ILIKE '%' || p_search || '%')
          AND (p_email_hash IS NULL OR p.email_hash = p_email_hash)
          AND (p_first_name_hash IS NULL OR pp.first_name_hash = p_first_name_hash)
          AND (p_last_name_hash IS NULL OR pp.last_name_hash = p_last_name_hash)
          AND (p_phone_hash IS NULL OR pp.phone_hash = p_phone_hash)
          AND (p_identity_no_hash IS NULL OR pi.identity_no_hash = p_identity_no_hash)
          AND (p_country_code IS NULL OR pp.country_code = p_country_code)
          AND (p_birth_date_from IS NULL OR pp.birth_date >= p_birth_date_from)
          AND (p_birth_date_to IS NULL OR pp.birth_date <= p_birth_date_to)
          AND (p_date_from IS NULL OR p.registered_at >= p_date_from)
          AND (p_date_to IS NULL OR p.registered_at <= p_date_to)
          AND (p_category_id IS NULL OR EXISTS (
              SELECT 1 FROM auth.player_classification pcl
              WHERE pcl.player_id = p.id AND pcl.player_category_id = p_category_id
          ))
          AND (p_group_id IS NULL OR EXISTS (
              SELECT 1 FROM auth.player_classification pcl
              WHERE pcl.player_id = p.id AND pcl.player_group_id = p_group_id
          ))
        ORDER BY p.registered_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION auth.player_list IS 'Paginated player list for backoffice with filters: status, email, name/phone hash (exact match), category, group, country, date range. Includes category and groups via LEFT JOIN LATERAL.';
