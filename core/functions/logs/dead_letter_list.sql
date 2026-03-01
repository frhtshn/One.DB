CREATE OR REPLACE FUNCTION logs.dead_letter_list(
    p_status VARCHAR(50) DEFAULT NULL,
    p_event_type VARCHAR(255) DEFAULT NULL,
    p_tenant_id VARCHAR(100) DEFAULT NULL,
    p_cluster_id VARCHAR(50) DEFAULT NULL,
    p_failure_category VARCHAR(100) DEFAULT NULL,
    p_consumer_name VARCHAR(255) DEFAULT NULL,
    p_from_date TIMESTAMPTZ DEFAULT NULL,
    p_to_date TIMESTAMPTZ DEFAULT NULL,
    p_search_text TEXT DEFAULT NULL,
    p_include_archived BOOLEAN DEFAULT FALSE,
    p_page INT DEFAULT 1,
    p_page_size INT DEFAULT 20,
    p_sort_by VARCHAR(50) DEFAULT 'created_at',
    p_sort_dir VARCHAR(4) DEFAULT 'DESC'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset INT;
    v_total_count INT;
    v_items JSONB;
    v_safe_search TEXT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    v_safe_search := NULL;
    IF p_search_text IS NOT NULL THEN
        v_safe_search := replace(replace(replace(p_search_text, '\', '\\'), '%', '\%'), '_', '\_');
    END IF;

    WITH filtered AS (
        SELECT m.id, m.event_id, m.event_type, m.tenant_id,
               m.cluster_id, m.consumer_name, m.exception_message,
               m.retry_count, m.manual_retry_count, m.status,
               m.failure_category, m.correlation_id,
               m.created_at, m.updated_at
        FROM logs.dead_letter_messages m
        WHERE (p_status IS NULL OR m.status = p_status)
          AND (p_event_type IS NULL OR m.event_type = p_event_type)
          AND (p_tenant_id IS NULL OR m.tenant_id = p_tenant_id)
          AND (p_cluster_id IS NULL OR m.cluster_id = p_cluster_id)
          AND (p_failure_category IS NULL OR m.failure_category = p_failure_category)
          AND (p_consumer_name IS NULL OR m.consumer_name = p_consumer_name)
          AND (p_from_date IS NULL OR m.created_at >= p_from_date)
          AND (p_to_date IS NULL OR m.created_at <= p_to_date)
          AND (v_safe_search IS NULL
               OR m.exception_message ILIKE '%' || v_safe_search || '%' ESCAPE '\'
               OR m.event_type ILIKE '%' || v_safe_search || '%' ESCAPE '\'
               OR m.consumer_name ILIKE '%' || v_safe_search || '%' ESCAPE '\')
          AND (p_include_archived = TRUE OR m.is_archived = FALSE)
    )
    SELECT
        (SELECT COUNT(*) FROM filtered),
        (SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id', f.id, 'eventId', f.event_id, 'eventType', f.event_type,
            'tenantId', f.tenant_id, 'clusterId', f.cluster_id,
            'consumerName', f.consumer_name, 'exceptionMessage', f.exception_message,
            'retryCount', f.retry_count, 'manualRetryCount', f.manual_retry_count,
            'status', f.status, 'failureCategory', f.failure_category,
            'correlationId', f.correlation_id,
            'createdAt', f.created_at, 'updatedAt', f.updated_at
        )), '[]'::JSONB)
        FROM (
            SELECT * FROM filtered
            ORDER BY
                CASE WHEN p_sort_by = 'created_at' AND p_sort_dir = 'DESC' THEN filtered.created_at END DESC,
                CASE WHEN p_sort_by = 'created_at' AND p_sort_dir = 'ASC' THEN filtered.created_at END ASC,
                CASE WHEN p_sort_by = 'updated_at' AND p_sort_dir = 'DESC' THEN filtered.updated_at END DESC,
                CASE WHEN p_sort_by = 'updated_at' AND p_sort_dir = 'ASC' THEN filtered.updated_at END ASC,
                CASE WHEN p_sort_by = 'retry_count' AND p_sort_dir = 'DESC' THEN filtered.retry_count END DESC,
                CASE WHEN p_sort_by = 'retry_count' AND p_sort_dir = 'ASC' THEN filtered.retry_count END ASC,
                filtered.created_at DESC
            LIMIT p_page_size OFFSET v_offset
        ) f)
    INTO v_total_count, v_items;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size,
        'totalPages', CEIL(v_total_count::DECIMAL / GREATEST(p_page_size, 1))
    );
END;
$$;
