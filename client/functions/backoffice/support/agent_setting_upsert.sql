-- ================================================================
-- AGENT_SETTING_UPSERT: Agent ayarı oluştur/güncelle
-- ================================================================
-- Per-tenant agent profilini upsert eder.
-- Aynı user_id için aktif kayıt varsa günceller, yoksa oluşturur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.agent_setting_upsert(BIGINT, VARCHAR, BOOLEAN, INT, TEXT);

CREATE OR REPLACE FUNCTION support.agent_setting_upsert(
    p_user_id                   BIGINT,
    p_display_name              VARCHAR(100) DEFAULT NULL,
    p_is_available              BOOLEAN DEFAULT false,
    p_max_concurrent_tickets    INT DEFAULT 10,
    p_skills                    TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_setting_id    BIGINT;
    v_skills_jsonb  JSONB;
BEGIN
    -- Zorunlu alan kontrolü
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.user-id-required';
    END IF;

    -- max_concurrent_tickets validasyonu
    IF p_max_concurrent_tickets < 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-max-tickets';
    END IF;

    -- Skills JSONB'ye çevir
    IF p_skills IS NOT NULL THEN
        BEGIN
            v_skills_jsonb := p_skills::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-skills-format';
        END;
    ELSE
        v_skills_jsonb := '[]'::JSONB;
    END IF;

    -- Upsert: ON CONFLICT unique index (user_id WHERE is_active = true)
    INSERT INTO support.agent_settings (
        user_id, display_name, is_available, max_concurrent_tickets,
        skills, is_active, created_at, updated_at
    ) VALUES (
        p_user_id, p_display_name, p_is_available, p_max_concurrent_tickets,
        v_skills_jsonb, true, NOW(), NOW()
    )
    ON CONFLICT (user_id) WHERE is_active = true
    DO UPDATE SET
        display_name           = EXCLUDED.display_name,
        is_available           = EXCLUDED.is_available,
        max_concurrent_tickets = EXCLUDED.max_concurrent_tickets,
        skills                 = EXCLUDED.skills,
        updated_at             = NOW()
    RETURNING id INTO v_setting_id;

    RETURN v_setting_id;
END;
$$;

COMMENT ON FUNCTION support.agent_setting_upsert IS 'Creates or updates per-tenant agent settings. Uses upsert on unique user_id index.';
