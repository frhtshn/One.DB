DROP TABLE IF EXISTS affiliate.player_affiliate_current CASCADE;

-- Oyuncunun güncel affiliate ataması
-- History tablosunu sorgulamadan hızlı erişim için denormalize tablo
CREATE TABLE affiliate.player_affiliate_current (
    player_id bigint PRIMARY KEY,           -- Oyuncu referansı
    affiliate_id bigint NOT NULL,           -- Güncel affiliate referansı
    campaign_id bigint,                     -- Güncel kampanya referansı
    assigned_at timestamp without time zone NOT NULL DEFAULT now()  -- Atama zamanı
);
