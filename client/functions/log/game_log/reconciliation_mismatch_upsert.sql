-- ================================================================
-- RECONCILIATION_MISMATCH_UPSERT: Uyuşmazlık kaydı oluştur
-- ================================================================
-- Reconciliation job'ı tarafından tespit edilen round/transaction
-- bazlı uyuşmazlıkları kaydeder.
-- ================================================================

DROP FUNCTION IF EXISTS game_log.reconciliation_mismatch_upsert(
    BIGINT, VARCHAR(100), VARCHAR(100), VARCHAR(50),
    DECIMAL(18,8), DECIMAL(18,8), VARCHAR(20), VARCHAR(20), TEXT
);

CREATE OR REPLACE FUNCTION game_log.reconciliation_mismatch_upsert(
    p_report_id               BIGINT,
    p_external_round_id       VARCHAR(100) DEFAULT NULL,
    p_external_transaction_id VARCHAR(100) DEFAULT NULL,
    p_mismatch_type           VARCHAR(50) DEFAULT NULL,
    p_our_amount              DECIMAL(18,8) DEFAULT NULL,
    p_provider_amount         DECIMAL(18,8) DEFAULT NULL,
    p_our_status              VARCHAR(20) DEFAULT NULL,
    p_provider_status         VARCHAR(20) DEFAULT NULL,
    p_details                 TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    v_id      BIGINT;
    v_details JSONB;
BEGIN
    -- ------------------------------------------------
    -- Zorunlu alan kontrolleri
    -- ------------------------------------------------
    IF p_report_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.reconciliation.provider-required');
    END IF;

    IF p_mismatch_type IS NULL OR TRIM(p_mismatch_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = format('error.reconciliation.date-required');
    END IF;

    -- ------------------------------------------------
    -- Details parse
    -- ------------------------------------------------
    v_details := CASE
        WHEN p_details IS NOT NULL AND TRIM(p_details) <> ''
        THEN p_details::JSONB
        ELSE NULL
    END;

    -- ------------------------------------------------
    -- INSERT
    -- ------------------------------------------------
    INSERT INTO game_log.reconciliation_mismatches (
        report_id,
        external_round_id,
        external_transaction_id,
        mismatch_type,
        our_amount,
        provider_amount,
        our_status,
        provider_status,
        details,
        resolution_status,
        created_at
    ) VALUES (
        p_report_id,
        NULLIF(TRIM(p_external_round_id), ''),
        NULLIF(TRIM(p_external_transaction_id), ''),
        TRIM(p_mismatch_type),
        p_our_amount,
        p_provider_amount,
        NULLIF(TRIM(p_our_status), ''),
        NULLIF(TRIM(p_provider_status), ''),
        v_details,
        'open',
        NOW()
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game_log.reconciliation_mismatch_upsert(BIGINT, VARCHAR(100), VARCHAR(100), VARCHAR(50), DECIMAL(18,8), DECIMAL(18,8), VARCHAR(20), VARCHAR(20), TEXT)
    IS 'Create reconciliation mismatch record for round/transaction level discrepancies';
