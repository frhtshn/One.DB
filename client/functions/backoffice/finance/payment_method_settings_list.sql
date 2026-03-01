-- ================================================================
-- PAYMENT_METHOD_SETTINGS_LIST: Cashier metot listesi (cursor pagination)
-- ================================================================
-- p_provider_ids: Backend core'dan aktif provider ID'lerini geçirir.
-- NULL ise tüm metotlar (BO admin görünümü).
-- Shadow mode filtresi: shadow metotlar sadece test oyuncularına.
-- Cursor pagination: (display_order, id) bazlı, OFFSET yok.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_settings_list(BIGINT[], BIGINT, VARCHAR, BOOLEAN, BOOLEAN, TEXT, INTEGER, INTEGER, BIGINT);

CREATE OR REPLACE FUNCTION finance.payment_method_settings_list(
    p_provider_ids BIGINT[] DEFAULT NULL,
    p_player_id BIGINT DEFAULT NULL,
    p_payment_type VARCHAR(50) DEFAULT NULL,
    p_is_enabled BOOLEAN DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_cursor_order INTEGER DEFAULT NULL,
    p_cursor_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_items JSONB;
    v_last_order INTEGER;
    v_last_id BIGINT;
    v_has_more BOOLEAN;
    v_is_shadow_tester BOOLEAN := false;
BEGIN
    -- Shadow tester kontrolü (player_id verilmişse)
    IF p_player_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM auth.shadow_testers WHERE player_id = p_player_id
        ) INTO v_is_shadow_tester;
    END IF;

    -- Metot listesi (subquery ile LIMIT uygulanır)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'paymentMethodId', sub.payment_method_id,
            'providerId', sub.provider_id,
            'providerCode', sub.provider_code,
            'externalMethodId', sub.external_method_id,
            'paymentMethodCode', sub.payment_method_code,
            'paymentMethodName', COALESCE(sub.custom_name, sub.payment_method_name),
            'paymentType', sub.payment_type,
            'paymentSubtype', sub.payment_subtype,
            'channel', sub.channel,
            'iconUrl', COALESCE(sub.custom_icon_url, sub.icon_url),
            'logoUrl', sub.logo_url,
            'allowDeposit', sub.allow_deposit,
            'allowWithdrawal', sub.allow_withdrawal,
            'supportsRefund', sub.supports_refund,
            'features', sub.features,
            'requiresKycLevel', sub.requires_kyc_level,
            'isMobile', sub.is_mobile,
            'isDesktop', sub.is_desktop,
            'isFeatured', sub.is_featured,
            'displayOrder', sub.display_order,
            'rolloutStatus', sub.rollout_status,
            'depositProcessingTime', sub.deposit_processing_time,
            'withdrawalProcessingTime', sub.withdrawal_processing_time,
            'popularityScore', sub.popularity_score,
            'usageCount', sub.usage_count
        ) ORDER BY sub.display_order ASC, sub.id ASC
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT pms.*
        FROM finance.payment_method_settings pms
        WHERE (p_provider_ids IS NULL OR pms.provider_id = ANY(p_provider_ids))
          AND (p_payment_type IS NULL OR pms.payment_type = UPPER(TRIM(p_payment_type)))
          AND (p_is_enabled IS NULL OR pms.is_enabled = p_is_enabled)
          AND (p_is_visible IS NULL OR pms.is_visible = p_is_visible)
          AND (p_search IS NULL OR
               pms.payment_method_name ILIKE '%' || p_search || '%' OR
               pms.payment_method_code ILIKE '%' || p_search || '%' OR
               pms.custom_name ILIKE '%' || p_search || '%')
          -- Shadow mode filtresi
          AND (pms.rollout_status = 'production' OR v_is_shadow_tester = true)
          -- Cursor pagination
          AND (p_cursor_order IS NULL OR p_cursor_id IS NULL OR
               (pms.display_order, pms.id) > (p_cursor_order, p_cursor_id))
        ORDER BY pms.display_order ASC, pms.id ASC
        LIMIT p_limit + 1
    ) sub;

    -- has_more kontrolü (limit+1 kayıt geldiyse daha var)
    v_has_more := jsonb_array_length(v_items) > p_limit;

    -- Fazla kaydı kırp (son elemanı çıkar)
    IF v_has_more THEN
        v_items := v_items - p_limit;
    END IF;

    -- Son kaydın cursor bilgileri
    IF jsonb_array_length(v_items) > 0 THEN
        v_last_order := ((v_items->(jsonb_array_length(v_items) - 1))->>'displayOrder')::INTEGER;
        v_last_id := ((v_items->(jsonb_array_length(v_items) - 1))->>'paymentMethodId')::BIGINT;
    END IF;

    RETURN jsonb_build_object(
        'items', v_items,
        'nextCursorOrder', v_last_order,
        'nextCursorId', v_last_id,
        'hasMore', v_has_more
    );
END;
$$;

COMMENT ON FUNCTION finance.payment_method_settings_list IS 'Returns payment method list with cursor pagination (display_order, id). Supports provider filtering, shadow mode (testers see shadow methods), and text search. Auth-agnostic.';
