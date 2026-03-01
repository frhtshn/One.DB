-- ================================================================
-- RECONCILIATION_REPORT_LIST: Uzlaştırma raporlarını listele
-- ================================================================
-- Filtreleme: provider, status, tarih aralığı
-- Pagination: OFFSET/LIMIT
-- Her rapor için mismatch sayısını dahil eder
-- ================================================================

DROP FUNCTION IF EXISTS game_log.reconciliation_report_list(VARCHAR(50), VARCHAR(20), DATE, DATE, INT, INT);

CREATE OR REPLACE FUNCTION game_log.reconciliation_report_list(
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_status        VARCHAR(20) DEFAULT NULL,
    p_date_from     DATE DEFAULT NULL,
    p_date_to       DATE DEFAULT NULL,
    p_page          INT DEFAULT 1,
    p_page_size     INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_total  BIGINT;
    v_offset INT;
    v_items  JSONB;
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- ------------------------------------------------
    -- Toplam kayıt sayısı
    -- ------------------------------------------------
    SELECT COUNT(*) INTO v_total
    FROM game_log.reconciliation_reports r
    WHERE (p_provider_code IS NULL OR r.provider_code = p_provider_code)
      AND (p_status IS NULL OR r.status = p_status)
      AND (p_date_from IS NULL OR r.report_date >= p_date_from)
      AND (p_date_to IS NULL OR r.report_date <= p_date_to);

    -- ------------------------------------------------
    -- Sayfalı veri + mismatch count
    -- ------------------------------------------------
    SELECT COALESCE(jsonb_agg(item ORDER BY item->>'reportDate' DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id',                 r.id,
            'providerCode',       r.provider_code,
            'reportDate',         r.report_date,
            'currencyCode',       r.currency_code,
            'ourTotalBet',        r.our_total_bet,
            'ourTotalWin',        r.our_total_win,
            'ourTotalRounds',     r.our_total_rounds,
            'providerTotalBet',   r.provider_total_bet,
            'providerTotalWin',   r.provider_total_win,
            'providerTotalRounds', r.provider_total_rounds,
            'betDiff',            r.bet_diff,
            'winDiff',            r.win_diff,
            'status',             r.status,
            'mismatchCount',      COALESCE(mc.cnt, 0),
            'resolvedBy',         r.resolved_by,
            'resolvedAt',         r.resolved_at,
            'createdAt',          r.created_at,
            'updatedAt',          r.updated_at
        ) AS item
        FROM game_log.reconciliation_reports r
        LEFT JOIN LATERAL (
            SELECT COUNT(*) AS cnt
            FROM game_log.reconciliation_mismatches mm
            WHERE mm.report_id = r.id
        ) mc ON true
        WHERE (p_provider_code IS NULL OR r.provider_code = p_provider_code)
          AND (p_status IS NULL OR r.status = p_status)
          AND (p_date_from IS NULL OR r.report_date >= p_date_from)
          AND (p_date_to IS NULL OR r.report_date <= p_date_to)
        ORDER BY r.report_date DESC, r.id DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'total',    v_total,
        'page',     GREATEST(p_page, 1),
        'pageSize', p_page_size,
        'items',    v_items
    );
END;
$$;

COMMENT ON FUNCTION game_log.reconciliation_report_list(VARCHAR(50), VARCHAR(20), DATE, DATE, INT, INT)
    IS 'List reconciliation reports with filtering, pagination, and mismatch counts';
