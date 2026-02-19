-- =============================================
-- Tablo: support.player_notes
-- Açıklama: Ticket'tan bağımsız, oyuncu bazlı
--           kalıcı notlar. CRM tarzı oyuncu
--           profili notları (general, warning,
--           vip, compliance).
-- =============================================

DROP TABLE IF EXISTS support.player_notes CASCADE;

CREATE TABLE support.player_notes (
    id                  BIGSERIAL       PRIMARY KEY,
    player_id           BIGINT          NOT NULL,               -- Oyuncu ID
    note_type           VARCHAR(20)     NOT NULL DEFAULT 'general', -- general, warning, vip, compliance
    content             TEXT            NOT NULL,               -- Not içeriği
    is_pinned           BOOLEAN         NOT NULL DEFAULT false, -- Sabitlenmiş mi? (profilde üstte gösterilir)
    created_by          BIGINT          NOT NULL,               -- Notu yazan BO user_id
    is_active           BOOLEAN         NOT NULL DEFAULT true,  -- Soft delete
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE support.player_notes IS 'Persistent player notes independent of tickets. Used for CRM-style player profile annotations (warnings, VIP notes, compliance notes).';
