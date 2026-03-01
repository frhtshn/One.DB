-- ================================================================
-- OPERATION_TYPES_SYNC: Core→Tenant operasyon tipi senkronizasyonu
-- ================================================================
-- p_data TEXT → JSONB array cast.
-- Core DB catalog.operation_types'dan gelen veriyi
-- Tenant DB transaction.operation_types'a UPSERT eder.
-- ID bazlı eşleşme (Core ile aynı ID'ler kullanılır).
-- Auth-agnostic (backend provisioning sırasında çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.operation_types_sync(TEXT);

CREATE OR REPLACE FUNCTION transaction.operation_types_sync(
    p_data TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_data JSONB;
    v_elem JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Parametre kontrolleri
    IF p_data IS NULL OR TRIM(p_data) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.operation-type.data-required';
    END IF;

    v_data := p_data::JSONB;

    IF jsonb_typeof(v_data) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.operation-type.invalid-format';
    END IF;

    -- Her eleman için UPSERT (id bazlı)
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_data)
    LOOP
        INSERT INTO transaction.operation_types (
            id, code, wallet_effect,
            affects_balance, affects_locked
        ) VALUES (
            (v_elem->>'id')::SMALLINT,
            v_elem->>'code',
            (v_elem->>'wallet_effect')::SMALLINT,
            COALESCE((v_elem->>'affects_balance')::BOOLEAN, true),
            COALESCE((v_elem->>'affects_locked')::BOOLEAN, false)
        )
        ON CONFLICT (id) DO UPDATE SET
            code            = EXCLUDED.code,
            wallet_effect   = EXCLUDED.wallet_effect,
            affects_balance = EXCLUDED.affects_balance,
            affects_locked  = EXCLUDED.affects_locked;

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION transaction.operation_types_sync(TEXT) IS 'Syncs operation type catalog from Core DB. Accepts TEXT->JSONB array, UPSERT by id. Used during tenant provisioning. Auth-agnostic.';
