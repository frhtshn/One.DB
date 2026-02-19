-- ================================================================
-- TICKET_TAG_LIST: Ticket etiket listesi
-- ================================================================
-- Tüm aktif etiketleri listeler.
-- Ticket sayısı ile birlikte (her etiketin kaç ticketta kullanıldığı).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_tag_list();

CREATE OR REPLACE FUNCTION support.ticket_tag_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items     JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(sub.item ORDER BY sub.tag_name), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT
            jsonb_build_object(
                'id', tt.id,
                'name', tt.name,
                'color', tt.color,
                'ticketCount', COALESCE(ta.cnt, 0),
                'createdAt', tt.created_at
            ) AS item,
            tt.name AS tag_name
        FROM support.ticket_tags tt
        LEFT JOIN (
            SELECT tag_id, COUNT(*) AS cnt
            FROM support.ticket_tag_assignments
            GROUP BY tag_id
        ) ta ON ta.tag_id = tt.id
        WHERE tt.is_active = true
    ) sub;

    RETURN jsonb_build_object('items', v_items);
END;
$$;

COMMENT ON FUNCTION support.ticket_tag_list IS 'Lists all active ticket tags with usage count (how many tickets each tag is assigned to).';
