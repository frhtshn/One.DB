-- ================================================================
-- PLAYER_BONUS_REQUEST_LIST: Oyuncunun kendi taleplerini listele
-- ================================================================
-- Oyuncu perspektifinden talep listesi döner.
-- BO-internal alanlar (assigned_to_id, reviewed_by_id, priority)
-- gizlenir. Tamamlanan taleplerde çevrim bilgisi dahil edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.player_bonus_request_list(BIGINT, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION bonus.player_bonus_request_list(
    p_player_id BIGINT,
    p_status    VARCHAR(20) DEFAULT NULL,
    p_page      INT DEFAULT 1,
    p_page_size INT DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM bonus.bonus_requests r
    WHERE r.player_id = p_player_id
      AND (p_status IS NULL OR r.status = p_status);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', r.id,
            'requestType', r.request_type,
            'displayName', COALESCE(
                s.display_name ->> 'tr',
                s.display_name ->> 'en',
                r.request_type
            ),
            'description', r.description,
            'status', r.status,
            'requestedAmount', r.requested_amount,
            'approvedAmount', r.approved_amount,
            'approvedCurrency', r.approved_currency,
            'reviewNote', r.review_note,
            'bonusAwardId', r.bonus_award_id,
            'createdAt', r.created_at,
            'reviewedAt', r.reviewed_at,
            'wagering', CASE
                WHEN r.status = 'completed' AND r.bonus_award_id IS NOT NULL THEN (
                    SELECT jsonb_build_object(
                        'hasWagering', COALESCE(ba.wagering_target IS NOT NULL AND ba.wagering_target > 0, false),
                        'wageringTarget', ba.wagering_target,
                        'wageringProgress', ba.wagering_progress,
                        'progressPercent', CASE
                            WHEN ba.wagering_target IS NOT NULL AND ba.wagering_target > 0
                            THEN ROUND((ba.wagering_progress / ba.wagering_target * 100)::NUMERIC, 2)
                            ELSE NULL
                        END,
                        'expiresAt', ba.expires_at
                    )
                    FROM bonus.bonus_awards ba
                    WHERE ba.id = r.bonus_award_id
                )
                ELSE jsonb_build_object('hasWagering', false)
            END
        ) AS item
        FROM bonus.bonus_requests r
        LEFT JOIN bonus.bonus_request_settings s
            ON s.bonus_type_code = r.request_type AND s.is_active = true
        WHERE r.player_id = p_player_id
          AND (p_status IS NULL OR r.status = p_status)
        ORDER BY r.created_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', GREATEST(p_page, 1),
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION bonus.player_bonus_request_list IS 'Player-facing bonus request list. Hides BO-internal fields (assignee, reviewer, priority). Includes wagering progress for completed requests.';
