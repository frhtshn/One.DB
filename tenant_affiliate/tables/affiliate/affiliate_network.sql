-- =============================================
-- Tablo: affiliate.affiliate_network
-- Açıklama: Affiliate ağ yapısı (Sub-Affiliate / MLM)
-- Parent-child ilişkilerini tanımlar
-- Çok katmanlı affiliate ağı için hiyerarşi yapısı
-- =============================================

DROP TABLE IF EXISTS affiliate.affiliate_network CASCADE;

CREATE TABLE affiliate.affiliate_network (
    affiliate_id bigint PRIMARY KEY,                       -- Affiliate ID (FK: affiliate.affiliates)
    parent_affiliate_id bigint,                            -- Üst affiliate ID (NULL = kök düğüm)
    level smallint NOT NULL DEFAULT 0,                     -- Hiyerarşi seviyesi (root = 0)
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE affiliate.affiliate_network IS 'Affiliate network hierarchy for multi-level marketing and sub-affiliate structures';
