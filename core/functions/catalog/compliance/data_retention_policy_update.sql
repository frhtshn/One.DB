-- ================================================================
-- DATA_RETENTION_POLICY_UPDATE: Veri saklama kuralını günceller
-- NULL parametreler mevcut değeri korur (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_update(INT, VARCHAR, INT, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_update(
    p_id INT,
    p_data_category VARCHAR(50) DEFAULT NULL,
    p_retention_days INT DEFAULT NULL,
    p_legal_reference VARCHAR(100) DEFAULT NULL,
    p_description VARCHAR(255) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_jurisdiction_id INT;
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    SELECT drp.jurisdiction_id INTO v_current_jurisdiction_id
    FROM catalog.data_retention_policies drp
    WHERE drp.id = p_id;

    IF v_current_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.data-retention-policy.not-found';
    END IF;

    -- Data category değişiyorsa kontrol et
    IF p_data_category IS NOT NULL THEN
        IF p_data_category NOT IN (
            'kyc_data', 'transaction_logs', 'player_data', 'affiliate_logs', 'game_logs', 'audit_logs'
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.data-category-invalid';
        END IF;

        -- Yeni kategori ile duplicate kontrolü
        IF EXISTS(
            SELECT 1 FROM catalog.data_retention_policies drp
            WHERE drp.jurisdiction_id = v_current_jurisdiction_id
              AND drp.data_category = p_data_category
              AND drp.id != p_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.data-retention-policy.already-exists';
        END IF;
    END IF;

    -- Retention days değişiyorsa kontrol et
    IF p_retention_days IS NOT NULL AND p_retention_days <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.retention-days-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.data_retention_policies SET
        data_category = COALESCE(p_data_category, data_category),
        retention_days = COALESCE(p_retention_days, retention_days),
        legal_reference = COALESCE(TRIM(p_legal_reference), legal_reference),
        description = COALESCE(TRIM(p_description), description),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_update IS 'Updates a data retention policy. NULL values keep existing data.';
