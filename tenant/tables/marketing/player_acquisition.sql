DROP TABLE IF EXISTS marketing.player_acquisition CASCADE;

CREATE TABLE marketing.player_acquisition (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,
    tenant_id bigint NOT NULL,

    acquisition_type varchar(30) NOT NULL,
        -- AFFILIATE / ORGANIC / PAID / ADMIN

    affiliate_id bigint,
    campaign_id bigint,
    tracking_code varchar(100),
    click_id uuid,

    acquired_at timestamp without time zone NOT NULL DEFAULT now(),

    created_by varchar(30) NOT NULL DEFAULT 'SYSTEM',

    UNIQUE (player_id, tenant_id)
);
