-- =============================================
-- Tablo: affiliate_audit.user_actions
-- Açıklama: Affiliate kullanıcı işlem kayıtları
-- Panel üzerinde yapılan tüm kritik işlemler
-- Compliance ve audit trail için
-- =============================================

DROP TABLE IF EXISTS affiliate_audit.user_actions CASCADE;

CREATE TABLE affiliate_audit.user_actions (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    user_id bigint NOT NULL,                               -- İşlemi yapan kullanıcı ID
    session_id bigint,                                     -- Oturum ID (FK: login_sessions)
    action_type varchar(50) NOT NULL,                      -- İşlem tipi (aşağıda listeli)
    entity_type varchar(50),                               -- Etkilenen varlık tipi: USER, CAMPAIGN, PAYOUT, etc.
    entity_id bigint,                                      -- Etkilenen varlık ID
    action_data jsonb,                                     -- İşlem detayları (eski/yeni değerler)
    ip_address inet,                                       -- IP adresi
    user_agent varchar(500),                               -- Tarayıcı bilgisi
    performed_at timestamp without time zone NOT NULL DEFAULT now() -- İşlem zamanı
);

COMMENT ON TABLE affiliate_audit.user_actions IS 'Audit trail of all critical user actions in affiliate panel for compliance and security';

-- =============================================
-- action_type Değerleri:
--
-- Kullanıcı İşlemleri:
--   USER_CREATED, USER_UPDATED, USER_DELETED, USER_STATUS_CHANGED
--   PASSWORD_CHANGED, PASSWORD_RESET_REQUESTED
--
-- Kampanya İşlemleri:
--   CAMPAIGN_CREATED, CAMPAIGN_UPDATED, CAMPAIGN_PAUSED
--   TRACKING_LINK_GENERATED
--
-- Alt Affiliate İşlemleri:
--   SUB_AFFILIATE_INVITED, SUB_AFFILIATE_USER_CREATED
--   NETWORK_SETTINGS_CHANGED
--
-- Finansal İşlemler:
--   PAYOUT_REQUESTED, PAYOUT_CANCELLED
--   PAYMENT_METHOD_ADDED, PAYMENT_METHOD_REMOVED
--
-- Raporlama:
--   REPORT_EXPORTED, REPORT_VIEWED
-- =============================================
