-- =============================================
-- Tablo: messaging.user_message_drafts
-- Açıklama: Admin mesaj taslak ve yönetim tablosu
-- Draft → Scheduled → Published / Cancelled akışı
-- Filtre bazlı alıcı çözümlemesi parametreleri
-- Backend poll ile zamanlanmış yayınlama
-- =============================================

DROP TABLE IF EXISTS messaging.user_message_drafts CASCADE;

CREATE TABLE messaging.user_message_drafts (
    id SERIAL PRIMARY KEY,                                     -- Benzersiz draft kimliği
    sender_id BIGINT NOT NULL,                                 -- Gönderen admin ID (FK: security.users)
    subject VARCHAR(500) NOT NULL,                             -- Mesaj konusu
    body TEXT NOT NULL,                                        -- Mesaj içeriği (HTML)
    message_type VARCHAR(30) NOT NULL DEFAULT 'announcement',  -- Mesaj tipi: announcement, maintenance, policy, system
    priority VARCHAR(10) NOT NULL DEFAULT 'normal',            -- Öncelik: normal, important, urgent

    -- Filtre alanları (AND kombinasyonu, NULL = filtre yok)
    company_id BIGINT,                                         -- Şirket filtresi
    client_ids BIGINT[],                                       -- Client filtresi (çoklu, NULL = filtre yok)
    department_id BIGINT,                                      -- Departman filtresi
    role_id BIGINT,                                            -- Rol filtresi

    -- Durum ve zamanlama
    status VARCHAR(20) NOT NULL DEFAULT 'draft',               -- draft / scheduled / published / cancelled
    scheduled_at TIMESTAMPTZ,                                   -- Zamanlanmış yayın tarihi (NULL = draft)
    published_at TIMESTAMPTZ,                                   -- Gerçek yayınlanma zamanı
    expires_at TIMESTAMPTZ,                                     -- Mesaj süre sonu

    -- İstatistik
    total_recipients INTEGER NOT NULL DEFAULT 0,               -- Yayınlanan alıcı sayısı

    -- Soft delete
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,                 -- Silindi mi?
    deleted_at TIMESTAMPTZ,                                    -- Silinme zamanı
    deleted_by BIGINT,                                         -- Silen kullanıcı ID
    cancelled_by BIGINT,                                       -- İptal eden kullanıcı ID

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),             -- Oluşturulma zamanı
    created_by BIGINT,                                         -- Oluşturan kullanıcı ID
    updated_at TIMESTAMPTZ                                     -- Son güncelleme zamanı
);

COMMENT ON TABLE messaging.user_message_drafts IS 'Admin message draft and management table. Status flow: draft → scheduled → published / cancelled. Filter-based recipient resolution on publish. Backend poll for scheduled publishing.';
