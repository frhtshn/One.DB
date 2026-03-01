-- =============================================
-- Tablo: tracking.player_affiliate_current
-- Açıklama: Oyuncu güncel affiliate ataması
-- Hızlı erişim için denormalize tablo
-- History tablosunu sorgulamadan direkt okuma sağlar
-- =============================================

DROP TABLE IF EXISTS tracking.player_affiliate_current CASCADE;

CREATE TABLE tracking.player_affiliate_current (
    player_id bigint PRIMARY KEY,                          -- Oyuncu ID (FK: tenant.players)
    affiliate_id bigint NOT NULL,                          -- Güncel affiliate ID (FK: affiliate.affiliates)
    campaign_id bigint,                                    -- Güncel kampanya ID (FK: campaign.campaigns)
    assigned_at timestamp without time zone NOT NULL DEFAULT now() -- Atama zamanı
);

COMMENT ON TABLE tracking.player_affiliate_current IS 'Current player-affiliate assignment for fast lookup without querying history table';
