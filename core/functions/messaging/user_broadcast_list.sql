-- ================================================================
-- USER_BROADCAST_LIST: Broadcast listesini döner
-- Filtre bazlı arama: company, tenant, tip ve metin araması
-- Sayfalama ve toplam kayıt sayısı dahil
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_broadcast_list(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS messaging.user_broadcast_list(BIGINT, BIGINT, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.user_broadcast_list(
    p_company_id    BIGINT DEFAULT NULL,              -- Şirket filtresi
    p_tenant_id     BIGINT DEFAULT NULL,              -- Tenant filtresi
    p_message_type  VARCHAR(30) DEFAULT NULL,         -- Tip filtresi
    p_search        VARCHAR(200) DEFAULT NULL,         -- Konu araması
    p_offset        INTEGER DEFAULT 0,                -- Sayfalama başlangıcı
    p_limit         INTEGER DEFAULT 20                -- Sayfa boyutu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_items JSONB;
BEGIN
    -- Toplam kayıt sayısı
    SELECT count(*) INTO v_total
    FROM messaging.user_message_broadcasts b
    WHERE b.is_deleted = FALSE
      AND (p_company_id IS NULL OR b.company_id = p_company_id)
      AND (p_tenant_id IS NULL OR b.tenant_id = p_tenant_id)
      AND (p_message_type IS NULL OR b.message_type = p_message_type)
      AND (p_search IS NULL OR b.subject ILIKE '%' || p_search || '%');

    -- Sayfalı sonuçlar
    SELECT COALESCE(jsonb_agg(row_data), '[]'::JSONB) INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', b.id,
            'sender_id', b.sender_id,
            'sender_name', u.first_name || ' ' || u.last_name,
            'subject', b.subject,
            'message_type', b.message_type,
            'priority', b.priority,
            'company_id', b.company_id,
            'tenant_id', b.tenant_id,
            'department_id', b.department_id,
            'role_id', b.role_id,
            'expires_at', b.expires_at,
            'total_recipients', b.total_recipients,
            'read_count', b.read_count,
            'created_at', b.created_at
        ) AS row_data
        FROM messaging.user_message_broadcasts b
        LEFT JOIN security.users u ON u.id = b.sender_id
        WHERE b.is_deleted = FALSE
          AND (p_company_id IS NULL OR b.company_id = p_company_id)
          AND (p_tenant_id IS NULL OR b.tenant_id = p_tenant_id)
          AND (p_message_type IS NULL OR b.message_type = p_message_type)
          AND (p_search IS NULL OR b.subject ILIKE '%' || p_search || '%')
        ORDER BY b.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'total', v_total,
        'offset', p_offset,
        'limit', p_limit,
        'items', v_items
    );
END;
$$;

COMMENT ON FUNCTION messaging.user_broadcast_list(BIGINT, BIGINT, VARCHAR, VARCHAR, INTEGER, INTEGER) IS 'List broadcasts with company, tenant, type and search filters. Returns paginated results with total count.';
