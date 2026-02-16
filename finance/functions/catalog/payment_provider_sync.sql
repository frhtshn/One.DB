-- ================================================================
-- PAYMENT_PROVIDER_SYNC: Core DB'den payment provider senkronizasyonu
-- ================================================================
-- Backend, Core DB'den PAYMENT tipli provider'ları alıp
-- bu fonksiyona TEXT (JSONB array) olarak geçirir.
-- Her eleman için UPSERT yapılır (id bazlı).
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_provider_sync(TEXT);

CREATE OR REPLACE FUNCTION catalog.payment_provider_sync(
    p_providers TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_providers JSONB;
    v_elem JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Parametre kontrolü
    IF p_providers IS NULL OR TRIM(p_providers) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.data-required';
    END IF;

    v_providers := p_providers::JSONB;

    -- JSONB array doğrulama
    IF jsonb_typeof(v_providers) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.invalid-format';
    END IF;

    -- Her eleman için UPSERT
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_providers)
    LOOP
        INSERT INTO catalog.payment_providers (
            id,
            provider_code,
            provider_name,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            (v_elem->>'id')::BIGINT,
            UPPER(TRIM(v_elem->>'provider_code')),
            TRIM(v_elem->>'provider_name'),
            COALESCE((v_elem->>'is_active')::BOOLEAN, true),
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            provider_code = UPPER(TRIM(EXCLUDED.provider_code)),
            provider_name = TRIM(EXCLUDED.provider_name),
            is_active = EXCLUDED.is_active,
            updated_at = NOW();

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION catalog.payment_provider_sync(TEXT) IS 'Syncs payment-type providers from Core DB. Accepts TEXT->JSONB array, performs id-based UPSERT. Returns number of upserted providers.';
