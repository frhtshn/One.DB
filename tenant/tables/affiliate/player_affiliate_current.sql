DROP TABLE IF EXISTS affiliate.player_affiliate_current CASCADE;

CREATE TABLE affiliate.player_affiliate_current (
    player_id bigint NOT NULL,
    tenant_id bigint NOT NULL,

    affiliate_id bigint,
    campaign_id bigint,

    assigned_at timestamp without time zone NOT NULL,

    PRIMARY KEY (player_id, tenant_id)
);
