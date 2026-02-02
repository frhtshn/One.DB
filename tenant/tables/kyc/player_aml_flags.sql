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
    -- STRUCTURING: Yapılandırma (limitleri aşmamak için parçalı işlem)
    -- RAPID_MOVEMENT: Hızlı para hareketi (yatır-çek)
    -- UNUSUAL_PATTERN: Olağandışı işlem paterni
    -- LARGE_TRANSACTION: Büyük tekil işlem
    -- CUMULATIVE_THRESHOLD: Kümülatif eşik aşımı
    -- THIRD_PARTY: Üçüncü taraf ödeme şüphesi
    -- SCREENING_ALERT: Tarama uyarısı (PEP/Sanctions)
    -- BEHAVIORAL: Davranışsal şüphe
    -- GEO_MISMATCH: Coğrafi uyuşmazlık
    -- MANUAL: Manuel eklenen uyarı

    -- Uyarı seviyesi
    severity varchar(20) NOT NULL,                -- Ciddiyet seviyesi
    -- LOW: Düşük - izle
    -- MEDIUM: Orta - incele
    -- HIGH: Yüksek - acil inceleme
    -- CRITICAL: Kritik - hemen aksiyon

    -- Uyarı durumu
    status varchar(30) NOT NULL DEFAULT 'OPEN',   -- Durum
    -- OPEN: Açık - inceleme bekliyor
    -- INVESTIGATING: İnceleniyor
    -- ESCALATED: Üst seviyeye iletildi
    -- SAR_FILED: SAR dosyalandı
    -- CLOSED_NO_ACTION: Kapatıldı - aksiyon gerekmedi
    -- CLOSED_ACTION_TAKEN: Kapatıldı - aksiyon alındı
    -- FALSE_POSITIVE: Yanlış pozitif

    -- Uyarı detayları
    description text NOT NULL,                    -- Uyarı açıklaması
    detection_method varchar(30) NOT NULL,        -- Tespit yöntemi
    -- AUTOMATED: Otomatik kural
    -- MANUAL: Manuel tespit
    -- EXTERNAL: Harici bildirim

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
    -- NO_SUSPICIOUS_ACTIVITY: Şüpheli aktivite yok
    -- SUSPICIOUS_CONFIRMED: Şüpheli aktivite doğrulandı
    -- REQUIRES_SAR: SAR gerekli
    -- ACCOUNT_CLOSURE: Hesap kapatma
    -- ENHANCED_MONITORING: Gelişmiş izleme

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
CREATE INDEX idx_player_aml_open ON kyc.player_aml_flags(status, severity) WHERE status IN ('OPEN', 'INVESTIGATING', 'ESCALATED');
CREATE INDEX idx_player_aml_assigned ON kyc.player_aml_flags(assigned_to) WHERE status IN ('OPEN', 'INVESTIGATING');
CREATE INDEX idx_player_aml_sar ON kyc.player_aml_flags(sar_required) WHERE sar_required = true AND sar_filed_at IS NULL;
