-- ================================================================
-- PROVIDER_TYPE_DELETE: Provider tipi siler
-- Sadece SuperAdmin kullanabilir (IDOR korumalı)
-- Bağlı provider varsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_type_delete(
    p_caller_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.provider_types pt WHERE pt.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-type.not-found';
    END IF;

    -- Bağlı provider kontrolü
    IF EXISTS(SELECT 1 FROM catalog.providers p WHERE p.provider_type_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider-type.has-providers';
    END IF;

    -- Sil
    DELETE FROM catalog.provider_types WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_delete IS 'Deletes a provider type. SuperAdmin only. Fails if providers exist.';
