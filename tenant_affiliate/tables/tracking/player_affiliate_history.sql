DROP TABLE IF EXISTS affiliate.player_affiliate_history CASCADE;

-- Oyuncu-Affiliate ilişki geçmişi (Audit)
-- Oyuncunun hangi affiliate'lere ne zaman atandığını takip eder
CREATE TABLE tracking.player_affiliate_history (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,              -- Oyuncu referansı
    affiliate_id bigint,                    -- Affiliate referansı
    campaign_id bigint,                     -- Kampanya referansı
    action varchar(30) NOT NULL,            -- ASSIGNED / TRANSFERRED / REMOVED
    reason varchar(255),                    -- İşlem sebebi
    valid_from timestamp without time zone NOT NULL DEFAULT now(),  -- Geçerlilik başlangıcı
    valid_to timestamp without time zone,   -- Geçerlilik bitişi (NULL = aktif)
    performed_by_type varchar(30) NOT NULL, -- SYSTEM / BO_USER / AFFILIATE
    performed_by_id bigint,                 -- İşlemi yapan ID
    created_at timestamp without time zone NOT NULL DEFAULT now()
);
