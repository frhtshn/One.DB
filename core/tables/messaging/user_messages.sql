-- =============================================
-- Tablo: messaging.user_messages
-- Açıklama: Kullanıcı mesaj kutusu (inbox)
-- Toplu (publish) ve birebir (direct) mesajlar
-- Her alıcı için ayrı satır
-- Aylık partition (created_at) - retention: 180 gün
-- Okunma ve silinme (soft delete) takibi
-- =============================================

DROP TABLE IF EXISTS messaging.user_messages CASCADE;

CREATE TABLE messaging.user_messages (
    id BIGSERIAL,                                              -- Benzersiz mesaj kimliği
    recipient_id BIGINT NOT NULL,                              -- Alıcı kullanıcı ID (FK: security.users)
    sender_id BIGINT NOT NULL,                                 -- Gönderen kullanıcı ID (FK: security.users)
    draft_id INTEGER,                                          -- Bağlı draft ID (NULL = direct mesaj)

    -- İçerik (her satırda dolu)
    subject VARCHAR(500) NOT NULL,                             -- Mesaj konusu
    body TEXT NOT NULL,                                        -- Mesaj içeriği (HTML)
    message_type VARCHAR(30) NOT NULL DEFAULT 'direct',        -- Mesaj tipi: direct, announcement, maintenance, policy, system
    priority VARCHAR(10) NOT NULL DEFAULT 'normal',            -- Öncelik: normal, important, urgent
    expires_at TIMESTAMP WITHOUT TIME ZONE,                    -- Opsiyonel süre sonu

    -- Okunma durumu
    is_read BOOLEAN NOT NULL DEFAULT FALSE,                    -- Okundu mu?
    read_at TIMESTAMP WITHOUT TIME ZONE,                       -- Okunma zamanı

    -- Kullanıcı perspektifinden soft delete
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,                 -- Kullanıcı sildi mi?
    deleted_at TIMESTAMP WITHOUT TIME ZONE,                    -- Silinme zamanı

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),

    PRIMARY KEY (id, created_at)                               -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE messaging.user_messages_default PARTITION OF messaging.user_messages DEFAULT;

COMMENT ON TABLE messaging.user_messages IS 'User inbox for published and direct messages. Subject/body always populated per row. draft_id links to user_message_drafts for published messages (NULL for direct). Partitioned monthly by created_at. Retention: 180 days.';

-- message_type değerleri:
-- direct: Birebir mesaj
-- announcement: Genel duyuru
-- maintenance: Bakım bildirimi
-- policy: Politika değişikliği
-- system: Otomatik sistem bildirimi
