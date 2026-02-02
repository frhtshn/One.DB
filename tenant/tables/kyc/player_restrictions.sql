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
    -- cooling_off: Soğuma dönemi (kısa süreli, geri alınamaz)
    -- self_exclusion: Kendini dışlama (uzun süreli, ciddi)

    -- Kısıtlama kapsamı
    scope varchar(30) NOT NULL DEFAULT 'all',     -- Kapsam
    -- all: Tüm oyunlar
    -- casino: Sadece casino
    -- sports: Sadece spor bahisleri
    -- live: Sadece canlı oyunlar

    -- Durum
    status varchar(20) NOT NULL DEFAULT 'active', -- Durum
    -- active: Aktif kısıtlama
    -- expired: Süresi dolmuş
    -- revoked: Admin tarafından kaldırıldı

    -- Tarihler
    starts_at timestamp NOT NULL DEFAULT now(),   -- Başlangıç tarihi
    ends_at timestamp,                            -- Bitiş tarihi (NULL = süresiz/kalıcı)

    -- Oyuncunun belirttiği sebep
    reason varchar(500),                          -- Kısıtlama sebebi

    -- Kim tarafından belirlendi
    set_by varchar(20) NOT NULL DEFAULT 'player', -- Belirleyen
    -- player: Oyuncu kendisi
    -- admin: Admin/Destek
    -- regulator: Düzenleyici kurum

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
