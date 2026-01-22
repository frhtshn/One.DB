DROP TABLE IF EXISTS affiliate.player_affiliate_history CASCADE;

CREATE TABLE affiliate.player_affiliate_history (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,
    tenant_id bigint NOT NULL,

    affiliate_id bigint,
    campaign_id bigint,

    action varchar(30) NOT NULL,
        -- ASSIGNED
        -- TRANSFERRED
        -- REMOVED

    reason varchar(255),

    valid_from timestamp without time zone NOT NULL DEFAULT now(),
    valid_to timestamp without time zone,

    performed_by_type varchar(30) NOT NULL,
        -- SYSTEM
        -- BO_USER
        -- AFFILIATE

    performed_by_id bigint,
        -- bo_user_id / affiliate_user_id

    created_at timestamp without time zone NOT NULL DEFAULT now()
);
