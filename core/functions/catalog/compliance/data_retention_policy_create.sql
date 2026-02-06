-- ================================================================
-- DATA_RETENTION_POLICY_CREATE: Yeni veri saklama kuralı oluşturur
-- Aynı jurisdiction + data_category kombinasyonu kontrol edilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_create(INT, VARCHAR, INT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_create(
    p_jurisdiction_id INT,
    p_data_category VARCHAR(50),
    p_retention_days INT,
    p_legal_reference VARCHAR(100) DEFAULT NULL,
    p_description VARCHAR(255) DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id INT;
BEGIN
    -- Jurisdiction kontrolü
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.jurisdiction-required';
    END IF;

    -- Jurisdiction varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Data category kontrolü
    IF p_data_category IS NULL OR p_data_category NOT IN (
        'kyc_data', 'transaction_logs', 'player_data', 'affiliate_logs', 'game_logs', 'audit_logs'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.data-category-invalid';
    END IF;

    -- Retention days kontrolü
    IF p_retention_days IS NULL OR p_retention_days <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.retention-days-invalid';
    END IF;

    -- Duplicate kontrolü (aynı jurisdiction + data_category)
    IF EXISTS(
        SELECT 1 FROM catalog.data_retention_policies drp
        WHERE drp.jurisdiction_id = p_jurisdiction_id AND drp.data_category = p_data_category
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.data-retention-policy.already-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.data_retention_policies (
        jurisdiction_id,
        data_category,
        retention_days,
        legal_reference,
        description,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_jurisdiction_id,
        p_data_category,
        p_retention_days,
        TRIM(p_legal_reference),
        TRIM(p_description),
        TRUE,
        NOW(),
        NOW()
    )
    RETURNING catalog.data_retention_policies.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_create IS 'Creates a data retention policy for a jurisdiction. One policy per jurisdiction+category combination.';
