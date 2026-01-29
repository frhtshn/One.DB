-- =============================================
-- Player Restrictions (Oyuncu Kısıtlamaları)
-- Cooling Off ve Self Exclusion
-- Oyuncunun kendini geçici veya kalıcı olarak kısıtlaması
-- =============================================

DROP TABLE IF EXISTS kyc.player_restrictions CASCADE;

CREATE TABLE kyc.player_restrictions (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Kısıtlama tipi
    restriction_type varchar(30) NOT NULL,        -- Kısıtlama türü
    -- COOLING_OFF: Soğuma dönemi (kısa süreli, geri alınamaz)
    -- SELF_EXCLUSION: Kendini dışlama (uzun süreli, ciddi)

    -- Kısıtlama kapsamı
    scope varchar(30) NOT NULL DEFAULT 'ALL',     -- Kapsam
    -- ALL: Tüm oyunlar
    -- CASINO: Sadece casino
    -- SPORTS: Sadece spor bahisleri
    -- LIVE: Sadece canlı oyunlar

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'ACTIVE', -- Durum
    -- ACTIVE: Aktif kısıtlama
    -- EXPIRED: Süresi dolmuş
    -- REVOKED: Admin tarafından kaldırıldı

    -- Tarihler
    starts_at timestamp NOT NULL DEFAULT now(),   -- Başlangıç tarihi
    ends_at timestamp,                            -- Bitiş tarihi (NULL = süresiz/kalıcı)

    -- Oyuncunun belirttiği sebep
    reason varchar(500),                          -- Kısıtlama sebebi

    -- Kim tarafından belirlendi
    set_by varchar(20) NOT NULL DEFAULT 'PLAYER', -- Belirleyen
    -- PLAYER: Oyuncu kendisi
    -- ADMIN: Admin/Destek
    -- REGULATOR: Düzenleyici kurum

    -- Yeniden aktivasyon
    can_be_revoked boolean NOT NULL DEFAULT false,-- İptal edilebilir mi?
    min_duration_days int,                        -- Minimum süre (gün)
    reinstatement_requested_at timestamp,         -- Yeniden açılma talebi tarihi
    reinstatement_approved_at timestamp,          -- Yeniden açılma onay tarihi
    reinstatement_approved_by bigint,             -- Onaylayan admin ID

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_restrictions IS 'Player self-imposed restrictions including cooling-off periods and self-exclusion for responsible gaming';
