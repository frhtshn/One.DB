-- =============================================
-- Tablo: support.tickets
-- Açıklama: Ana ticket tablosu. Tüm kanallardan
--           gelen talepleri birleştirir (phone,
--           live_chat, email, social_media).
--           Tam yaşam döngüsü takibi.
-- =============================================

DROP TABLE IF EXISTS support.tickets CASCADE;

CREATE TABLE support.tickets (
    id                  BIGSERIAL       PRIMARY KEY,

    -- Oyuncu bilgisi
    player_id           BIGINT          NOT NULL,               -- Oyuncu ID

    -- Ticket bilgileri
    category_id         BIGINT,                                 -- Ticket kategorisi (FK → ticket_categories)
    channel             VARCHAR(20)     NOT NULL,               -- Kanal: phone, live_chat, email, social_media
    subject             VARCHAR(255)    NOT NULL,               -- Ticket başlığı
    description         TEXT            NOT NULL,               -- İlk mesaj / açıklama

    -- Öncelik ve durum
    priority            SMALLINT        NOT NULL DEFAULT 1,     -- 0=low, 1=normal, 2=high, 3=urgent
    status              VARCHAR(20)     NOT NULL DEFAULT 'open', -- open, assigned, in_progress, pending_player, resolved, closed, reopened, cancelled

    -- Atama alanları
    assigned_to_id      BIGINT,                                 -- Atanan temsilci (BO user_id — plain BIGINT, cross-DB)
    assigned_at         TIMESTAMPTZ,                            -- Atama zamanı

    -- Kaynak bilgisi
    created_by_id       BIGINT          NOT NULL,               -- Ticket'ı oluşturan (player_id veya user_id)
    created_by_type     VARCHAR(10)     NOT NULL,               -- PLAYER veya BO_USER
    resolved_by_id      BIGINT,                                 -- Çözen temsilci
    resolved_at         TIMESTAMPTZ,                            -- Çözüm zamanı
    closed_at           TIMESTAMPTZ,                            -- Kapatma zamanı

    -- Zaman damgaları
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE support.tickets IS 'Support tickets from all channels (phone, live_chat, email, social_media). Tracks full lifecycle from creation through resolution and closure.';
