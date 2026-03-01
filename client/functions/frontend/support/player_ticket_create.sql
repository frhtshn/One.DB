-- ================================================================
-- PLAYER_TICKET_CREATE: Oyuncu ticket oluştur
-- ================================================================
-- Oyuncu self-service ticket oluşturma.
-- Anti-abuse kontrolleri dahil:
--   - Açık ticket limiti (max_open_tickets)
--   - Cooldown süresi (son kapatmadan bu yana bekleme)
-- Parametreler backend tarafından core.tenant_settings'ten
-- okunup iletilir — fonksiyon Core DB'ye erişmez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_ticket_create(BIGINT, VARCHAR, VARCHAR, TEXT, BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION support.player_ticket_create(
    p_player_id             BIGINT,
    p_channel               VARCHAR(20),
    p_subject               VARCHAR(255),
    p_description           TEXT,
    p_category_id           BIGINT DEFAULT NULL,
    p_max_open_tickets      INT DEFAULT 1,
    p_cooldown_minutes      INT DEFAULT 0
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_open_count        INT;
    v_last_closure      TIMESTAMPTZ;
    v_ticket_id         BIGINT;
BEGIN
    -- Anti-abuse: Açık ticket limiti
    IF p_max_open_tickets > 0 THEN
        SELECT COUNT(*) INTO v_open_count
        FROM support.tickets
        WHERE player_id = p_player_id
          AND status IN ('open', 'assigned', 'in_progress', 'pending_player', 'reopened');

        IF v_open_count >= p_max_open_tickets THEN
            RAISE EXCEPTION USING ERRCODE = 'P0429', MESSAGE = 'error.support.max-open-tickets-reached';
        END IF;
    END IF;

    -- Anti-abuse: Cooldown kontrolü
    IF p_cooldown_minutes > 0 THEN
        SELECT GREATEST(
            MAX(CASE WHEN status = 'closed' THEN closed_at END),
            MAX(CASE WHEN status = 'cancelled' THEN updated_at END)
        )
        INTO v_last_closure
        FROM support.tickets
        WHERE player_id = p_player_id
          AND status IN ('closed', 'cancelled');

        IF v_last_closure IS NOT NULL
           AND NOW() - v_last_closure < (p_cooldown_minutes || ' minutes')::INTERVAL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0429', MESSAGE = 'error.support.ticket-cooldown-active';
        END IF;
    END IF;

    -- Ticket oluştur (ticket_create sarmalayıcısı)
    v_ticket_id := support.ticket_create(
        p_player_id     := p_player_id,
        p_channel        := p_channel,
        p_subject        := p_subject,
        p_description    := p_description,
        p_category_id    := p_category_id,
        p_priority       := 1,              -- Oyuncu ticket'ı her zaman normal öncelik
        p_created_by_id  := p_player_id,
        p_created_by_type := 'PLAYER'
    );

    RETURN v_ticket_id;
END;
$$;

COMMENT ON FUNCTION support.player_ticket_create IS 'Player self-service ticket creation with anti-abuse controls (max open tickets, cooldown). Parameters are passed by backend from core.tenant_settings.';
