-- =============================================
-- Player Jurisdiction (Oyuncu Yetki Alanı)
-- Oyuncunun tabi olduğu yasal düzenleme
-- Kayıt, doğrulama ve mevcut jurisdiction takibi
-- =============================================

DROP TABLE IF EXISTS kyc.player_jurisdiction CASCADE;

CREATE TABLE kyc.player_jurisdiction (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL UNIQUE,             -- Oyuncu ID (1:1 ilişki)

    -- Kayıt anındaki bilgiler
    registration_country_code character(2) NOT NULL, -- Kayıt ülkesi (IP/beyan)
    registration_ip_country character(2),         -- IP'den tespit edilen ülke
    declared_country_code character(2),           -- Oyuncunun beyan ettiği ülke

    -- Doğrulanmış bilgiler
    verified_country_code character(2),           -- KYC ile doğrulanan ülke
    verified_at timestamp,                        -- Doğrulama tarihi

    -- Aktif jurisdiction
    jurisdiction_id int NOT NULL,                 -- Tabi olunan jurisdiction (core.jurisdictions)
    jurisdiction_assigned_at timestamp NOT NULL DEFAULT now(),
    jurisdiction_assigned_by varchar(20) DEFAULT 'SYSTEM',
    -- SYSTEM: Otomatik atama
    -- ADMIN: Manuel atama
    -- KYC: KYC doğrulaması sonrası

    -- Değişiklik geçmişi için önceki jurisdiction
    previous_jurisdiction_id int,
    jurisdiction_changed_at timestamp,
    jurisdiction_change_reason varchar(255),

    -- Coğrafi kısıtlama durumu
    geo_status varchar(20) NOT NULL DEFAULT 'ALLOWED',
    -- ALLOWED: İzin verilen bölge
    -- BLOCKED: Engelli bölge
    -- RESTRICTED: Kısıtlı (bazı oyunlar yasak)
    -- PENDING_REVIEW: İnceleme bekliyor

    geo_block_reason varchar(255),                -- Engelleme sebebi
    geo_reviewed_at timestamp,                    -- Son inceleme tarihi
    geo_reviewed_by bigint,                       -- İnceleyen admin ID

    -- Son konum kontrolü
    last_ip_address varchar(45),                  -- Son IP adresi
    last_ip_country character(2),                 -- Son IP ülkesi
    last_geo_check_at timestamp,                  -- Son kontrol zamanı

    -- VPN/Proxy tespiti
    vpn_detected boolean DEFAULT false,           -- VPN tespit edildi mi?
    vpn_detection_count int DEFAULT 0,            -- Toplam VPN tespit sayısı
    last_vpn_detection_at timestamp,              -- Son VPN tespiti

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_jurisdiction IS 'Tracks which jurisdiction/regulation applies to each player based on registration, verification, and current location';

-- Indexes
CREATE INDEX idx_player_jurisdiction_country ON kyc.player_jurisdiction(verified_country_code);
CREATE INDEX idx_player_jurisdiction_jid ON kyc.player_jurisdiction(jurisdiction_id);
CREATE INDEX idx_player_jurisdiction_geo ON kyc.player_jurisdiction(geo_status);
