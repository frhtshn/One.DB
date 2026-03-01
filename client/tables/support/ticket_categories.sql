-- =============================================
-- Tablo: support.ticket_categories
-- Açıklama: Ticket kategori ağacı. Hiyerarşik
--           yapı (parent_id ile alt kategoriler).
--           JSONB ile çoklu dil desteği.
-- =============================================

DROP TABLE IF EXISTS support.ticket_categories CASCADE;

CREATE TABLE support.ticket_categories (
    id                  BIGSERIAL       PRIMARY KEY,
    parent_id           BIGINT,                                 -- Üst kategori ID (self-ref). NULL = kök kategori
    code                VARCHAR(50)     NOT NULL,               -- Kategori kodu (unique, aktifler arasında)
    name                JSONB           NOT NULL,               -- Lokalize ad: {"tr":"Yatırım Sorunu","en":"Deposit Issue"}
    description         JSONB,                                  -- Lokalize açıklama
    display_order       INT             NOT NULL DEFAULT 0,     -- Sıralama
    is_active           BOOLEAN         NOT NULL DEFAULT true,  -- Soft delete
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Aktif kategorilerde benzersiz kod
CREATE UNIQUE INDEX IF NOT EXISTS uq_ticket_categories_code
    ON support.ticket_categories (code)
    WHERE is_active = true;

COMMENT ON TABLE support.ticket_categories IS 'Hierarchical ticket category tree for support tickets. Supports multi-language names via JSONB and parent-child relationships.';
