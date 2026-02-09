-- =============================================
-- Tablo: messaging.user_message_broadcasts
-- Açıklama: Kullanıcı toplu mesaj gönderim kaydı
-- Filtre bazlı alıcı çözümlemesi (company/tenant/department/role AND kombinasyonu)
-- İstatistik alanları: total_recipients, read_count
-- Soft delete destekli
-- =============================================

DROP TABLE IF EXISTS messaging.user_message_broadcasts CASCADE;

CREATE TABLE messaging.user_message_broadcasts (
    id SERIAL PRIMARY KEY,                                     -- Benzersiz broadcast kimliği
    sender_id BIGINT NOT NULL,                                 -- Gönderen kullanıcı ID (FK: security.users)
    subject VARCHAR(500) NOT NULL,                             -- Mesaj konusu
    body TEXT NOT NULL,                                        -- Mesaj içeriği (HTML)
    message_type VARCHAR(30) NOT NULL DEFAULT 'announcement',  -- Mesaj tipi: announcement, maintenance, policy, system
    priority VARCHAR(10) NOT NULL DEFAULT 'normal',            -- Öncelik: normal, important, urgent

    -- Filtre alanları (AND kombinasyonu, NULL = filtre yok)
    company_id BIGINT,                                         -- Şirket filtresi (NULL = tüm şirketler)
    tenant_id BIGINT,                                          -- Tenant filtresi (NULL = tüm tenant'lar)
    department_id BIGINT,                                      -- Departman filtresi (NULL = tüm departmanlar)
    role_id BIGINT,                                            -- Rol filtresi (NULL = tüm roller)

    expires_at TIMESTAMP WITHOUT TIME ZONE,                    -- Opsiyonel süre sonu
    total_recipients INTEGER NOT NULL DEFAULT 0,               -- Toplam alıcı sayısı
    read_count INTEGER NOT NULL DEFAULT 0,                     -- Okuyan kullanıcı sayısı
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,                 -- Soft delete
    deleted_at TIMESTAMP WITHOUT TIME ZONE,                    -- Silinme zamanı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),             -- Oluşturulma zamanı
    created_by BIGINT                                          -- Oluşturan kullanıcı ID
);

COMMENT ON TABLE messaging.user_message_broadcasts IS 'Broadcast message records for bulk user messaging. Filter-based recipient resolution (company/tenant/department/role AND combination). Each broadcast resolves to individual user_messages rows.';
