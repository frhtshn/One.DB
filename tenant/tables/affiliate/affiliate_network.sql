DROP TABLE IF EXISTS affiliate.affiliate_network CASCADE;

-- Affiliate Network yapısı (Sub-Affiliate / MLM hazır)
-- Parent-child ilişkilerini tanımlar
CREATE TABLE affiliate.affiliate_network (
    affiliate_id bigint PRIMARY KEY,        -- Affiliate referansı
    parent_affiliate_id bigint,             -- Üst affiliate (NULL = root)
    level smallint NOT NULL DEFAULT 0,      -- Seviye (root = 0)
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
