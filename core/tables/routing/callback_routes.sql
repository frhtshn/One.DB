-- =============================================
-- Tablo: routing.callback_routes
-- Açıklama: Callback yönlendirme haritaları
-- Provider callback'lerinin hangi tenant'a yönlendirileceğini belirler
-- route_key ile gelen istek doğru tenant'a ulaşır
-- =============================================

DROP TABLE IF EXISTS routing.callback_routes CASCADE;

CREATE TABLE routing.callback_routes (
    id bigserial PRIMARY KEY,                              -- Benzersiz route kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    route_key varchar(100) NOT NULL,                       -- Benzersiz yönlendirme anahtarı
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE routing.callback_routes IS 'Callback routing maps determining which tenant receives provider callbacks based on unique route keys';
