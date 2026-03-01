-- =============================================
-- Tablo: core.client_providers
-- Açıklama: Client provider etkinleştirme tablosu
-- Her client'in hangi provider'ları kullanacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.client_providers CASCADE;

CREATE TABLE core.client_providers (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    mode varchar(20) NOT NULL DEFAULT 'real',              -- Çalışma modu: real, demo, test
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu

    -- Shadow Mode (SHADOW_MODE)
    rollout_status VARCHAR(20) NOT NULL DEFAULT 'production', -- shadow: sadece test oyuncuları, production: herkes

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now(), -- Son güncelleme zamanı

    CONSTRAINT chk_client_providers_rollout CHECK (rollout_status IN ('shadow', 'production'))
);

COMMENT ON TABLE core.client_providers IS 'Client provider enablement table with shadow mode rollout support. rollout_status controls visibility: shadow (testers only) or production (all players).';
