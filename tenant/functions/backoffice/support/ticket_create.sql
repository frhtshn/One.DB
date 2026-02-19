-- ================================================================
-- TICKET_CREATE: Ticket oluştur (BO)
-- ================================================================
-- BO kullanıcısı oyuncu adına ticket oluşturur.
-- Anti-abuse kontrolleri YOK — BO kullanıcıları telefon/email
-- gibi kanallardan gelen talepleri özgürce kayıt altına alabilir.
-- Anti-abuse yalnızca player_ticket_create() fonksiyonunda uygulanır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_create(BIGINT, VARCHAR, VARCHAR, TEXT, BIGINT, SMALLINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_create(
    p_player_id         BIGINT,
    p_channel           VARCHAR(20),
    p_subject           VARCHAR(255),
    p_description       TEXT,
    p_category_id       BIGINT DEFAULT NULL,
    p_priority          SMALLINT DEFAULT 1,
    p_created_by_id     BIGINT DEFAULT NULL,
    p_created_by_type   VARCHAR(10) DEFAULT 'BO_USER'
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket_id     BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.player-required';
    END IF;

    IF p_subject IS NULL OR TRIM(p_subject) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.subject-required';
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.description-required';
    END IF;

    -- Channel validasyonu
    IF p_channel IS NULL OR p_channel NOT IN ('phone', 'live_chat', 'email', 'social_media') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-channel';
    END IF;

    -- Priority validasyonu (0=low, 1=normal, 2=high, 3=urgent)
    IF p_priority < 0 OR p_priority > 3 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-priority';
    END IF;

    -- created_by_type validasyonu
    IF p_created_by_type NOT IN ('PLAYER', 'BO_USER') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-created-by-type';
    END IF;

    -- Kategori kontrolü (varsa aktif mi?)
    IF p_category_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
        END IF;
    END IF;

    -- Ticket oluştur
    INSERT INTO support.tickets (
        player_id, category_id, channel, subject, description,
        priority, status, created_by_id, created_by_type,
        created_at, updated_at
    ) VALUES (
        p_player_id, p_category_id, p_channel, TRIM(p_subject), p_description,
        p_priority, 'open', COALESCE(p_created_by_id, p_player_id), p_created_by_type,
        NOW(), NOW()
    )
    RETURNING id INTO v_ticket_id;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        old_status, new_status, content, is_internal, created_at
    ) VALUES (
        v_ticket_id, 'CREATED', COALESCE(p_created_by_id, p_player_id), p_created_by_type,
        NULL, 'open', LEFT(p_description, 500), false, NOW()
    );

    RETURN v_ticket_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_create IS 'Creates a support ticket on behalf of a player. BO users bypass anti-abuse checks. Anti-abuse is enforced only in player_ticket_create.';
