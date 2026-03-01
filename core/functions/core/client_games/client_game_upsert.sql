-- ================================================================
-- TENANT_GAME_UPSERT: Tekil oyun aç/düzenle (customization)
-- ================================================================
-- BO admin tarafından tenant oyun ayarlarını düzenlemek için.
-- catalog.games validasyonu YAPILMAZ (cross-DB, backend doğrular).
-- Güncelleme sonrası sync_status = 'pending' olur.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_game_upsert(
    BIGINT, BIGINT, BIGINT,
    BOOLEAN, BOOLEAN, BOOLEAN, INTEGER,
    VARCHAR, VARCHAR, VARCHAR(50)[], VARCHAR(50)[],
    VARCHAR, VARCHAR(20)[],
    CHAR(2)[], CHAR(2)[],
    TIMESTAMP, TIMESTAMP
);

CREATE OR REPLACE FUNCTION core.tenant_game_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_game_id BIGINT,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_display_order INTEGER DEFAULT NULL,
    p_custom_name VARCHAR(255) DEFAULT NULL,
    p_custom_thumbnail_url VARCHAR(500) DEFAULT NULL,
    p_custom_categories VARCHAR(50)[] DEFAULT NULL,
    p_custom_tags VARCHAR(50)[] DEFAULT NULL,
    p_rtp_variant VARCHAR(20) DEFAULT NULL,
    p_allowed_platforms VARCHAR(20)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_allowed_countries CHAR(2)[] DEFAULT NULL,
    p_available_from TIMESTAMP DEFAULT NULL,
    p_available_until TIMESTAMP DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- game_id zorunlu
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    -- tenant_games kaydı mevcut olmalı (backend seed etmiş olmalı)
    IF NOT EXISTS(SELECT 1 FROM core.tenant_games WHERE tenant_id = p_tenant_id AND game_id = p_game_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-game.not-found';
    END IF;

    -- COALESCE güncelleme
    UPDATE core.tenant_games SET
        is_enabled = COALESCE(p_is_enabled, is_enabled),
        is_visible = COALESCE(p_is_visible, is_visible),
        is_featured = COALESCE(p_is_featured, is_featured),
        display_order = COALESCE(p_display_order, display_order),
        custom_name = COALESCE(p_custom_name, custom_name),
        custom_thumbnail_url = COALESCE(p_custom_thumbnail_url, custom_thumbnail_url),
        custom_categories = COALESCE(p_custom_categories, custom_categories),
        custom_tags = COALESCE(p_custom_tags, custom_tags),
        rtp_variant = COALESCE(p_rtp_variant, rtp_variant),
        allowed_platforms = COALESCE(p_allowed_platforms, allowed_platforms),
        blocked_countries = COALESCE(p_blocked_countries, blocked_countries),
        allowed_countries = COALESCE(p_allowed_countries, allowed_countries),
        available_from = COALESCE(p_available_from, available_from),
        available_until = COALESCE(p_available_until, available_until),
        sync_status = 'pending',
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE tenant_id = p_tenant_id AND game_id = p_game_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_game_upsert IS 'Updates tenant game customization (display_order, custom_name, blocked_countries, etc). COALESCE pattern. Sets sync_status=pending. IDOR protected.';
