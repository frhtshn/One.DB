-- =============================================
-- Player Limit History (Limit Değişiklik Geçmişi)
-- Tüm limit ve kısıtlama değişikliklerinin audit logu
-- Düzenleyici uyumluluk için gerekli
-- =============================================

DROP TABLE IF EXISTS kyc.player_limit_history CASCADE;

CREATE TABLE kyc.player_limit_history (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- İşlem tipi
    action_type varchar(50) NOT NULL,             -- İşlem türü
    -- LIMIT_CREATED: Limit oluşturuldu
    -- LIMIT_DECREASED: Limit azaltıldı (hemen aktif)
    -- LIMIT_INCREASE_REQUESTED: Limit artışı talep edildi
    -- LIMIT_INCREASE_ACTIVATED: Limit artışı aktif oldu
    -- LIMIT_REMOVED: Limit kaldırıldı
    -- RESTRICTION_STARTED: Kısıtlama başladı
    -- RESTRICTION_ENDED: Kısıtlama sona erdi
    -- REINSTATEMENT_REQUESTED: Yeniden açılma talep edildi
    -- REINSTATEMENT_APPROVED: Yeniden açılma onaylandı
    -- REINSTATEMENT_REJECTED: Yeniden açılma reddedildi

    -- Referans
    entity_type varchar(30) NOT NULL,             -- Kaynak tablo
    -- LIMIT: player_limits
    -- RESTRICTION: player_restrictions
    entity_id bigint NOT NULL,                    -- Kaynak kayıt ID

    -- Değişiklik detayları
    old_value jsonb,                              -- Eski değerler
    new_value jsonb,                              -- Yeni değerler

    -- Kim tarafından yapıldı
    performed_by varchar(20) NOT NULL,            -- İşlemi yapan
    -- PLAYER: Oyuncu
    -- ADMIN: Admin
    -- SYSTEM: Sistem otomatik
    admin_user_id bigint,                         -- Admin ise kullanıcı ID

    -- İşlem detayı
    reason varchar(500),                          -- İşlem sebebi/açıklama
    ip_address varchar(45),                       -- IP adresi
    user_agent varchar(500),                      -- Tarayıcı bilgisi

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_limit_history IS 'Audit log for all player limit and restriction changes for regulatory compliance';
