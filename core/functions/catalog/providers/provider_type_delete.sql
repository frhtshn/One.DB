-- ================================================================
-- PROVIDER_TYPE_DELETE: Provider tipi siler
-- Bagli provider varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_delete(BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_type_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolu
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.id-required';
    END IF;

    -- Mevcut kayit kontrolu
    IF NOT EXISTS(SELECT 1 FROM catalog.provider_types pt WHERE pt.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-type.not-found';
    END IF;

    -- Bagli provider kontrolu
    IF EXISTS(SELECT 1 FROM catalog.providers p WHERE p.provider_type_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider-type.has-providers';
    END IF;

    -- Sil
    DELETE FROM catalog.provider_types WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_delete IS 'Deletes a provider type. Fails if providers exist.';
