-- =============================================
-- Tablo: support.ticket_tag_assignments
-- Açıklama: Ticket ↔ tag M:N ilişkisi.
--           Her ticket'a birden fazla etiket
--           atanabilir.
-- =============================================

DROP TABLE IF EXISTS support.ticket_tag_assignments CASCADE;

CREATE TABLE support.ticket_tag_assignments (
    id                  BIGSERIAL       PRIMARY KEY,
    ticket_id           BIGINT          NOT NULL,               -- FK → tickets.id
    tag_id              BIGINT          NOT NULL,               -- FK → ticket_tags.id
    assigned_by         BIGINT,                                 -- Etiketleyen BO user_id
    assigned_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    -- Aynı ticket'a aynı tag iki kere atanamaz
    CONSTRAINT uq_ticket_tag_assignment UNIQUE (ticket_id, tag_id)
);

COMMENT ON TABLE support.ticket_tag_assignments IS 'Many-to-many relationship between tickets and tags. Each ticket can have multiple tags for flexible filtering.';
