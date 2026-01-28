-- ================================================================
-- USER_LIST: Kullanıcı listesi (paginated, filtrelenebilir)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_list(INT, INT, TEXT, SMALLINT, BIGINT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION security.user_list(
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 10,
    p_search TEXT DEFAULT NULL,
    p_status SMALLINT DEFAULT NULL,
    p_company_id BIGINT DEFAULT NULL,
    p_sort_by TEXT DEFAULT 'id',
    p_sort_order TEXT DEFAULT 'ASC'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset INT;
    v_total_count BIGINT;
    v_items JSONB;
    v_sort_column TEXT;
    v_sort_dir TEXT;
BEGIN
    -- Pagination offset hesapla
    v_offset := (p_page - 1) * p_page_size;

    -- Sort column doğrulama (SQL injection koruması)
    v_sort_column := CASE LOWER(COALESCE(p_sort_by, 'id'))
        WHEN 'id' THEN 'u.id'
        WHEN 'firstname' THEN 'u.first_name'
        WHEN 'lastname' THEN 'u.last_name'
        WHEN 'email' THEN 'u.email'
        WHEN 'username' THEN 'u.username'
        WHEN 'status' THEN 'u.status'
        WHEN 'createdat' THEN 'u.created_at'
        WHEN 'lastloginat' THEN 'u.last_login_at'
        ELSE 'u.id'
    END;

    -- Sort direction doğrulama
    v_sort_dir := CASE UPPER(COALESCE(p_sort_order, 'ASC'))
        WHEN 'DESC' THEN 'DESC'
        ELSE 'ASC'
    END;

    -- Total count hesapla
    SELECT COUNT(*)
    INTO v_total_count
    FROM security.users u
    WHERE (p_company_id IS NULL OR u.company_id = p_company_id)
      AND (p_status IS NULL OR u.status = p_status)
      AND (p_search IS NULL OR p_search = '' OR (
          u.email ILIKE '%' || p_search || '%' OR
          u.username ILIKE '%' || p_search || '%' OR
          u.first_name ILIKE '%' || p_search || '%' OR
          u.last_name ILIKE '%' || p_search || '%'
      ));

    -- Items listesi al
    EXECUTE format(
        'SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_key %s), ''[]''::jsonb)
         FROM (
             SELECT
                 jsonb_build_object(
                     ''id'', u.id,
                     ''companyId'', u.company_id,
                     ''firstName'', u.first_name,
                     ''lastName'', u.last_name,
                     ''email'', u.email,
                     ''username'', u.username,
                     ''status'', u.status,
                     ''isLocked'', u.is_locked,
                     ''twoFactorEnabled'', u.two_factor_enabled,
                     ''language'', u.language,
                     ''timezone'', u.timezone,
                     ''currency'', u.currency,
                     ''lastLoginAt'', u.last_login_at,
                     ''createdAt'', u.created_at,
                     ''roles'', COALESCE((
                         SELECT jsonb_agg(jsonb_build_object(
                             ''roleId'', r.id,
                             ''roleCode'', r.code,
                             ''roleName'', r.name
                         ))
                         FROM security.user_roles ur
                         JOIN security.roles r ON r.id = ur.role_id
                         WHERE ur.user_id = u.id
                     ), ''[]''::jsonb)
                 ) AS row_data,
                 %s AS sort_key
             FROM security.users u
             WHERE ($1 IS NULL OR u.company_id = $1)
               AND ($2 IS NULL OR u.status = $2)
               AND ($3 IS NULL OR $3 = '''' OR (
                   u.email ILIKE ''%%'' || $3 || ''%%'' OR
                   u.username ILIKE ''%%'' || $3 || ''%%'' OR
                   u.first_name ILIKE ''%%'' || $3 || ''%%'' OR
                   u.last_name ILIKE ''%%'' || $3 || ''%%''
               ))
             ORDER BY %s %s
             LIMIT $4 OFFSET $5
         ) sub',
        v_sort_dir,
        v_sort_column,
        v_sort_column,
        v_sort_dir
    )
    INTO v_items
    USING p_company_id, p_status, p_search, p_page_size, v_offset;

    -- Sonuç döndür
    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size,
        'totalPages', CEIL(v_total_count::DECIMAL / p_page_size)
    );
END;
$$;

COMMENT ON FUNCTION security.user_list IS 'Returns paginated user list with filters (search, status, company) and sorting';
