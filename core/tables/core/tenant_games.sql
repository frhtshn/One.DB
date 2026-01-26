-- =============================================
-- Tablo: core.tenant_games
-- Açıklama: Tenant oyun etkinleştirme tablosu
-- Her tenant'in hangi oyunları sunacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.tenant_games CASCADE;

CREATE TABLE core.tenant_games (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    game_id bigint NOT NULL,                               -- Oyun ID (FK: catalog.games)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);
