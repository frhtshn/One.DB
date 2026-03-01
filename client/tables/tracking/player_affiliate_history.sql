-- =============================================
-- Tablo: tracking.player_affiliate_history
-- Açıklama: Oyuncu-affiliate ilişki geçmişi
-- Oyuncunun hangi affiliate'lere ne zaman atandığını takip eder
-- Audit ve attribution hesaplaması için kullanılır
-- =============================================

DROP TABLE IF EXISTS tracking.player_affiliate_history CASCADE;

CREATE TABLE tracking.player_affiliate_history (
    id bigserial PRIMARY KEY,                              -- Benzersiz geçmiş kaydı kimliği
    player_id bigint NOT NULL,                             -- Oyuncu ID (FK: client.players)
    affiliate_id bigint,                                   -- Affiliate ID (FK: affiliate.affiliates)
    campaign_id bigint,                                    -- Kampanya ID (FK: campaign.campaigns)
    action varchar(30) NOT NULL,                           -- İşlem: ASSIGNED, TRANSFERRED, REMOVED
    reason varchar(255),                                   -- İşlem sebebi/açıklaması
    valid_from timestamp without time zone NOT NULL DEFAULT now(), -- Geçerlilik başlangıcı
    valid_to timestamp without time zone,                  -- Geçerlilik bitişi (NULL = aktif)
    performed_by_type varchar(30) NOT NULL,                -- İşlemi yapan tip: SYSTEM, BO_USER, AFFILIATE
    performed_by_id bigint,                                -- İşlemi yapan ID
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE tracking.player_affiliate_history IS 'Player-affiliate relationship history for audit trail and attribution calculations';
