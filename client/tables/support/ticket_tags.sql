-- =============================================
-- Tablo: support.ticket_tags
-- Açıklama: Client seviyesinde yeniden kullanılabilir
--           ticket etiketleri. Ticketları
--           kategorize etmek ve filtrelemek için.
-- =============================================

DROP TABLE IF EXISTS support.ticket_tags CASCADE;

CREATE TABLE support.ticket_tags (
    id                  BIGSERIAL       PRIMARY KEY,
    name                VARCHAR(50)     NOT NULL,               -- Etiket adı (unique, aktifler arasında)
    color               VARCHAR(7)      NOT NULL DEFAULT '#6B7280', -- HEX renk kodu
    is_active           BOOLEAN         NOT NULL DEFAULT true,  -- Soft delete
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Aktif etiketlerde benzersiz ad
CREATE UNIQUE INDEX IF NOT EXISTS uq_ticket_tags_name
    ON support.ticket_tags (name)
    WHERE is_active = true;

COMMENT ON TABLE support.ticket_tags IS 'Reusable tags for categorizing and filtering support tickets at client level.';
