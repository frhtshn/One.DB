-- =============================================
-- Tablo: support.agent_settings
-- Açıklama: Per-tenant müşteri temsilcisi profili.
--           Core DB'deki user'ın tenant'taki
--           destek ayarları: müsaitlik, kapasite,
--           yetenek kategorileri.
-- =============================================

DROP TABLE IF EXISTS support.agent_settings CASCADE;

CREATE TABLE support.agent_settings (
    id                          BIGSERIAL       PRIMARY KEY,
    user_id                     BIGINT          NOT NULL,               -- BO user_id (cross-DB, plain BIGINT)
    display_name                VARCHAR(100),                           -- Oyuncuya gösterilen ad (NULL ise core'daki ad kullanılır)
    is_available                BOOLEAN         NOT NULL DEFAULT false, -- Müsait mi? (online/offline toggle)
    max_concurrent_tickets      INT             NOT NULL DEFAULT 10,    -- Aynı anda taşıyabileceği max ticket
    skills                      JSONB           NOT NULL DEFAULT '[]',  -- Yetkin olduğu kategoriler: ["deposit","withdrawal","bonus"]
    is_active                   BOOLEAN         NOT NULL DEFAULT true,  -- Soft delete
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Aktif agent'larda benzersiz user_id
CREATE UNIQUE INDEX IF NOT EXISTS uq_agent_settings_user
    ON support.agent_settings (user_id)
    WHERE is_active = true;

COMMENT ON TABLE support.agent_settings IS 'Per-tenant support agent profile. Stores availability, capacity, and skill categories for ticket assignment.';
