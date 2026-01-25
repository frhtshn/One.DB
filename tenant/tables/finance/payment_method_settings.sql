DROP TABLE IF EXISTS finance.payment_method_settings CASCADE;

CREATE TABLE finance.payment_method_settings (
    id bigserial PRIMARY KEY,

    -- Core DB'den denormalize edilmiş alanlar (catalog.payment_methods + catalog.providers)
    payment_method_id bigint NOT NULL,
    payment_method_code varchar(100) NOT NULL,
    payment_method_name varchar(255) NOT NULL,
    provider_id bigint NOT NULL,
    provider_code varchar(50) NOT NULL,

    -- Tenant'a özel görünüm ayarları
    display_order int,
    is_visible boolean NOT NULL DEFAULT true,
    is_featured boolean NOT NULL DEFAULT false,

    -- Tenant'a özel özelleştirmeler
    custom_name varchar(255),
    custom_icon_url varchar(500),

    -- Ek metadata
    tags jsonb,
    metadata jsonb,

    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);
