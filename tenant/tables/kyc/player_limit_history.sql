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
    -- limit_created: Limit oluşturuldu
    -- limit_decreased: Limit azaltıldı (hemen aktif)
    -- limit_increase_requested: Limit artışı talep edildi
    -- limit_increase_activated: Limit artışı aktif oldu
    -- limit_removed: Limit kaldırıldı
    -- restriction_started: Kısıtlama başladı
    -- restriction_ended: Kısıtlama sona erdi
    -- reinstatement_requested: Yeniden açılma talep edildi
    -- reinstatement_approved: Yeniden açılma onaylandı
    -- reinstatement_rejected: Yeniden açılma reddedildi

    -- Referans
    entity_type varchar(30) NOT NULL,             -- Kaynak tablo
    -- limit: player_limits
    -- restriction: player_restrictions
    entity_id bigint NOT NULL,                    -- Kaynak kayıt ID

    -- Değişiklik detayları
    old_value jsonb,                              -- Eski değerler
    new_value jsonb,                              -- Yeni değerler

    -- Kim tarafından yapıldı
    performed_by varchar(20) NOT NULL,            -- İşlemi yapan
    -- player: Oyuncu
    -- admin: Admin
    -- system: Sistem otomatik
    admin_user_id bigint,                         -- Admin ise kullanıcı ID

    -- İşlem detayı
    reason varchar(500),                          -- İşlem sebebi/açıklama
    ip_address varchar(45),                       -- IP adresi
    user_agent varchar(500),                      -- Tarayıcı bilgisi

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_limit_history IS 'Audit log for all player limit and restriction changes for regulatory compliance';
