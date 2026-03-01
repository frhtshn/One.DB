-- ================================================================
-- TRANSACTION_TYPES_SYNC: Core→Client işlem tipi senkronizasyonu
-- ================================================================
-- p_data TEXT → JSONB array cast.
-- Core DB catalog.transaction_types'dan gelen veriyi
-- Client DB transaction.transaction_types'a UPSERT eder.
-- ID bazlı eşleşme (Core ile aynı ID'ler kullanılır).
-- Auth-agnostic (backend provisioning sırasında çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.transaction_types_sync(TEXT);

CREATE OR REPLACE FUNCTION transaction.transaction_types_sync(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.transaction-type.data-required';
    END IF;

    v_data := p_data::JSONB;

    IF jsonb_typeof(v_data) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.transaction-type.invalid-format';
    END IF;

    -- Her eleman için UPSERT (id bazlı)
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_data)
    LOOP
        INSERT INTO transaction.transaction_types (
            id, code, category, product,
            is_bonus, is_free, is_rollback, is_winning,
            is_reportable, is_active
        ) VALUES (
            (v_elem->>'id')::SMALLINT,
            v_elem->>'code',
            v_elem->>'category',
            v_elem->>'product',
            COALESCE((v_elem->>'is_bonus')::BOOLEAN, false),
            COALESCE((v_elem->>'is_free')::BOOLEAN, false),
            COALESCE((v_elem->>'is_rollback')::BOOLEAN, false),
            COALESCE((v_elem->>'is_winning')::BOOLEAN, false),
            COALESCE((v_elem->>'is_reportable')::BOOLEAN, true),
            COALESCE((v_elem->>'is_active')::BOOLEAN, true)
        )
        ON CONFLICT (id) DO UPDATE SET
            code          = EXCLUDED.code,
            category      = EXCLUDED.category,
            product       = EXCLUDED.product,
            is_bonus      = EXCLUDED.is_bonus,
            is_free       = EXCLUDED.is_free,
            is_rollback   = EXCLUDED.is_rollback,
            is_winning    = EXCLUDED.is_winning,
            is_reportable = EXCLUDED.is_reportable,
            is_active     = EXCLUDED.is_active;

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION transaction.transaction_types_sync(TEXT) IS 'Syncs transaction type catalog from Core DB. Accepts TEXT->JSONB array, UPSERT by id. Used during client provisioning. Auth-agnostic.';
