-- =============================================
-- Player AML Flags (AML Uyarıları)
-- Şüpheli aktivite kayıtları ve SAR'lar
-- Anti-Money Laundering uyumluluk takibi
-- =============================================

DROP TABLE IF EXISTS kyc.player_aml_flags CASCADE;

CREATE TABLE kyc.player_aml_flags (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID

    -- Uyarı tipi
    flag_type varchar(50) NOT NULL,               -- Uyarı türü
    -- structuring: Yapılandırma (limitleri aşmamak için parçalı işlem)
    -- rapid_movement: Hızlı para hareketi (yatır-çek)
    -- unusual_pattern: Olağandışı işlem paterni
    -- large_transaction: Büyük tekil işlem
    -- cumulative_threshold: Kümülatif eşik aşımı
    -- third_party: Üçüncü taraf ödeme şüphesi
    -- screening_alert: Tarama uyarısı (PEP/Sanctions)
    -- behavioral: Davranışsal şüphe
    -- geo_mismatch: Coğrafi uyuşmazlık
    -- manual: Manuel eklenen uyarı

    -- Uyarı seviyesi
    severity varchar(20) NOT NULL,                -- Ciddiyet seviyesi
    -- low: Düşük - izle
    -- medium: Orta - incele
    -- high: Yüksek - acil inceleme
    -- critical: Kritik - hemen aksiyon

    -- Uyarı durumu
    status varchar(30) NOT NULL DEFAULT 'open',   -- Durum
    -- open: Açık - inceleme bekliyor
    -- investigating: İnceleniyor
    -- escalated: Üst seviyeye iletildi
    -- sar_filed: SAR dosyalandı
    -- closed_no_action: Kapatıldı - aksiyon gerekmedi
    -- closed_action_taken: Kapatıldı - aksiyon alındı
    -- false_positive: Yanlış pozitif

    -- Uyarı detayları
    description text NOT NULL,                    -- Uyarı açıklaması
    detection_method varchar(30) NOT NULL,        -- Tespit yöntemi
    -- automated: Otomatik kural
    -- manual: Manuel tespit
    -- external: Harici bildirim

    rule_id varchar(50),                          -- Tetikleyen kural ID (otomatik için)
    rule_name varchar(100),                       -- Kural adı

    -- İlgili veriler
    related_transactions jsonb,                   -- İlgili işlem ID'leri
    -- [{ "id": 123, "type": "DEPOSIT", "amount": 5000, "date": "..." }]

    evidence_data jsonb,                          -- Kanıt verileri
    -- { "pattern": "...", "timeline": [...], "amounts": [...] }

    -- Eşikler ve tutarlar
    threshold_amount decimal(18,2),               -- Tetikleyen eşik tutarı
    actual_amount decimal(18,2),                  -- Gerçekleşen tutar
    currency_code character(3),                   -- Para birimi

    -- Zaman aralığı
    period_start timestamp,                       -- İzlenen dönem başlangıcı
    period_end timestamp,                         -- İzlenen dönem sonu
    transaction_count int,                        -- Dönemdeki işlem sayısı

    -- İnceleme
    assigned_to bigint,                           -- Atanan inceleyici
    assigned_at timestamp,                        -- Atama tarihi

    investigated_by bigint,                       -- İnceleyen admin
    investigation_started_at timestamp,           -- İnceleme başlangıcı
    investigation_notes text,                     -- İnceleme notları

    -- Karar
    decision varchar(50),                         -- Karar
    -- no_suspicious_activity: Şüpheli aktivite yok
    -- suspicious_confirmed: Şüpheli aktivite doğrulandı
    -- requires_sar: SAR gerekli
    -- account_closure: Hesap kapatma
    -- enhanced_monitoring: Gelişmiş izleme

    decision_by bigint,                           -- Karar veren admin
    decision_at timestamp,                        -- Karar tarihi
    decision_reason text,                         -- Karar gerekçesi

    -- SAR (Suspicious Activity Report)
    sar_required boolean DEFAULT false,           -- SAR gerekli mi?
    sar_reference varchar(100),                   -- SAR referans numarası
    sar_filed_at timestamp,                       -- SAR dosyalama tarihi
    sar_filed_by bigint,                          -- SAR dosyalayan admin

    -- Aksiyonlar
    actions_taken jsonb,                          -- Alınan aksiyonlar
    -- [{ "action": "BLOCK_WITHDRAWALS", "at": "...", "by": 123 }]

    -- Tarihler
    detected_at timestamp NOT NULL DEFAULT now(), -- Tespit tarihi
    closed_at timestamp,                          -- Kapatılma tarihi

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_aml_flags IS 'AML alerts, suspicious activity tracking, and SAR management for anti-money laundering compliance';

-- Indexes
CREATE INDEX idx_player_aml_player ON kyc.player_aml_flags(player_id);
CREATE INDEX idx_player_aml_status ON kyc.player_aml_flags(status);
CREATE INDEX idx_player_aml_type ON kyc.player_aml_flags(flag_type);
CREATE INDEX idx_player_aml_severity ON kyc.player_aml_flags(severity);
CREATE INDEX idx_player_aml_open ON kyc.player_aml_flags(status, severity) WHERE status IN ('open', 'investigating', 'escalated');
CREATE INDEX idx_player_aml_assigned ON kyc.player_aml_flags(assigned_to) WHERE status IN ('open', 'investigating');
CREATE INDEX idx_player_aml_sar ON kyc.player_aml_flags(sar_required) WHERE sar_required = true AND sar_filed_at IS NULL;
